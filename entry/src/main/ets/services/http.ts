import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';

export interface HttpResponse<T> {
  data: T;
  statusCode: number;
  headers: Object;
}

export interface HttpRequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Object;
  data?: Object | string;
  timeout?: number;
}

const BASE_URL = 'http://localhost:8000/api/v1';

export class HttpService {
  private static instance: HttpService;
  private httpClient: Object;

  private constructor() {
    this.httpClient = http.createHttp();
  }

  public static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  async request<T>(
    url: string,
    options: HttpRequestOptions = {}
  ): Promise<HttpResponse<T>> {
    const {
      method = 'GET',
      headers = {},
      data,
      timeout = 30000
    } = options;

    const fullUrl = url.startsWith('http') ? url : `${BASE_URL}${url}`;

    const defaultHeaders: Object = {
      'Content-Type': 'application/json',
      ...headers
    };

    try {
      const response = await (this.httpClient as { request: (url: string, opts: Object) => Promise<Object> }).request(fullUrl, {
        method: http.RequestMethod[method],
        header: defaultHeaders,
        extraData: data ? JSON.stringify(data) : undefined,
        connectTimeout: timeout,
        readTimeout: timeout
      });

      return {
        data: response['result'] as T,
        statusCode: response['responseCode'] as number,
        headers: response['header'] as Object
      };
    } catch (error) {
      const err = error as BusinessError;
      throw new Error(`HTTP request failed: ${err.message}`);
    }
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
    (this.httpClient as { destroy: () => void }).destroy();
  }
}

export const httpService = HttpService.getInstance();
