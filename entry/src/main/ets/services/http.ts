import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { Constants, getStorage } from '../utils';

export interface HttpResponse<T> {
  data: T;
  statusCode: number;
  headers: Record<string, string>;
}

export interface HttpRequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Record<string, string>;
  data?: Record<string, unknown> | string;
  timeout?: number;
  retryCount?: number;
}

export interface HttpError extends Error {
  statusCode?: number;
  response?: HttpResponse<unknown>;
  isNetworkError: boolean;
  isTimeout: boolean;
}

const DEFAULT_TIMEOUT = 30000;
const DEFAULT_RETRY_COUNT = 2;

interface HttpClient {
  request: (url: string, options: http.HttpRequestOptions) => Promise<http.HttpResponse>;
  destroy: () => void;
}

export class HttpService {
  private static instance: HttpService;
  private httpClient: HttpClient;
  private requestId: number = 0;
  private static baseUrl: string = 'http://localhost:8000/api/v1';

  private constructor() {
    this.httpClient = http.createHttp() as HttpClient;
  }

  public static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  public static getBaseUrl(): string {
    return HttpService.baseUrl;
  }

  public static setBaseUrl(url: string): void {
    HttpService.baseUrl = url;
  }

  private createError(message: string, statusCode?: number, response?: HttpResponse<unknown>, isNetworkError: boolean = false, isTimeout: boolean = false): HttpError {
    const error = new Error(message) as HttpError;
    error.statusCode = statusCode;
    error.response = response;
    error.isNetworkError = isNetworkError;
    error.isTimeout = isTimeout;
    return error;
  }

  private async requestWithRetry<T>(
    url: string,
    options: HttpRequestOptions,
    retryCount: number
  ): Promise<HttpResponse<T>> {
    const requestId = ++this.requestId;
    console.debug(`[HTTP][${requestId}] Request: ${options.method || 'GET'} ${url}`);

    try {
      const requestOptions = await this.buildRequestOptions(options);
      const response = await this.httpClient.request(url, requestOptions);
      const result = this.parseResponse<T>(response);
      console.debug(`[HTTP][${requestId}] Success: ${result.statusCode}`);
      return result;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[HTTP][${requestId}] Error: ${err.message} (code: ${err.code})`);

      if (retryCount > 0 && this.shouldRetry(err)) {
        console.debug(`[HTTP][${requestId}] Retrying (${retryCount} attempts left)...`);
        await this.delay(1000 * (DEFAULT_RETRY_COUNT - retryCount + 1));
        return this.requestWithRetry(url, options, retryCount - 1);
      }

      throw this.createHttpError(err);
    }
  }

  private async buildRequestOptions(options: HttpRequestOptions): Promise<http.HttpRequestOptions> {
    const {
      method = 'GET',
      headers = {},
      data,
      timeout = DEFAULT_TIMEOUT
    } = options;

    const defaultHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...headers
    };

    try {
      const token = await getStorage(Constants.STORAGE_KEY_TOKEN);
      if (token && typeof token === 'string') {
        defaultHeaders['Authorization'] = `Bearer ${token}`;
      }
    } catch (e) {
      console.debug('[HTTP] Failed to get auth token:', e);
    }

    return {
      method: http.RequestMethod[method],
      header: defaultHeaders,
      extraData: data ? (typeof data === 'string' ? data : JSON.stringify(data)) : undefined,
      connectTimeout: timeout,
      readTimeout: timeout
    };
  }

  private parseResponse<T>(response: http.HttpResponse): HttpResponse<T> {
    let data: T;
    try {
      const result = response.result as string | Record<string, unknown>;
      data = typeof result === 'string' ? JSON.parse(result) as T : result as T;
    } catch (e) {
      data = response.result as T;
    }

    const headers: Record<string, string> = {};
    const headerObj = response.header as Record<string, string>;
    for (const key in headerObj) {
      if (headerObj.hasOwnProperty(key)) {
        headers[key] = String(headerObj[key]);
      }
    }

    return {
      data,
      statusCode: response.responseCode,
      headers
    };
  }

  private shouldRetry(error: BusinessError): boolean {
    const retryCodes = [2, 4, 5];
    return retryCodes.includes(error.code);
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private createHttpError(error: BusinessError): HttpError {
    switch (error.code) {
      case 2:
        return this.createError('网络连接失败', undefined, undefined, true, false);
      case 4:
        return this.createError('请求超时', undefined, undefined, true, true);
      case 5:
        return this.createError('DNS解析失败', undefined, undefined, true, false);
      default:
        return this.createError(`HTTP请求失败: ${error.message}`, undefined, undefined, true, false);
    }
  }

  async request<T>(
    url: string,
    options: HttpRequestOptions = {}
  ): Promise<HttpResponse<T>> {
    const fullUrl = url.startsWith('http') ? url : `${HttpService.baseUrl}${url}`;
    const retryCount = options.retryCount ?? DEFAULT_RETRY_COUNT;
    return this.requestWithRetry<T>(fullUrl, options, retryCount);
  }

  async get<T>(url: string, options?: Omit<HttpRequestOptions, 'method'>): Promise<HttpResponse<T>> {
    return this.request<T>(url, { ...options, method: 'GET' });
  }

  async post<T>(url: string, data?: HttpRequestOptions['data'], options?: Omit<HttpRequestOptions, 'method' | 'data'>): Promise<HttpResponse<T>> {
    return this.request<T>(url, { ...options, method: 'POST', data });
  }

  async put<T>(url: string, data?: HttpRequestOptions['data'], options?: Omit<HttpRequestOptions, 'method' | 'data'>): Promise<HttpResponse<T>> {
    return this.request<T>(url, { ...options, method: 'PUT', data });
  }

  async delete<T>(url: string, options?: Omit<HttpRequestOptions, 'method'>): Promise<HttpResponse<T>> {
    return this.request<T>(url, { ...options, method: 'DELETE' });
  }

  destroy(): void {
    this.httpClient.destroy();
  }
}

export const httpService = HttpService.getInstance();