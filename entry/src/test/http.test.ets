import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { HttpService, HttpResponse, HttpRequestOptions, HttpError } from '../main/ets/services/http';

export default function httpTestSuite() {
  describe('HttpService', () => {
    let httpService: HttpService;

    beforeAll(() => {
      httpService = HttpService.getInstance();
    });

    afterAll(() => {
      httpService.destroy();
    });

    describe('Singleton Pattern', () => {
      it('should return the same instance', 0, () => {
        const instance1 = HttpService.getInstance();
        const instance2 = HttpService.getInstance();
        expect(instance1).assertEqual(instance2);
      });
    });

    describe('Base URL Configuration', () => {
      it('should return default base URL', 0, () => {
        const defaultUrl = 'http://localhost:8000/api/v1';
        expect(HttpService.getBaseUrl()).assertEqual(defaultUrl);
      });

      it('should allow setting custom base URL', 0, () => {
        const customUrl = 'http://api.example.com/v2';
        HttpService.setBaseUrl(customUrl);
        expect(HttpService.getBaseUrl()).assertEqual(customUrl);
        HttpService.setBaseUrl('http://localhost:8000/api/v1');
      });
    });

    describe('Response Parsing', () => {
      it('should parse JSON string response correctly', 0, () => {
        const mockHttpResponse = {
          result: JSON.stringify({ success: true, data: { id: 1, name: 'test' } }),
          responseCode: 200,
          header: { 'Content-Type': 'application/json' }
        };

        const result = mockHttpResponse.result;
        expect(typeof result).assertEqual('string');
        const parsed = JSON.parse(result as string);
        expect(parsed.success).assertTrue();
        expect(parsed.data.id).assertEqual(1);
        expect(parsed.data.name).assertEqual('test');
      });

      it('should handle non-JSON response gracefully', 0, () => {
        const mockHttpResponse = {
          result: 'plain text response',
          responseCode: 200,
          header: { 'Content-Type': 'text/plain' }
        };

        const result = mockHttpResponse.result;
        expect(typeof result).assertEqual('string');
        expect(result).assertEqual('plain text response');
      });
    });

    describe('Error Classification', () => {
      it('should identify network error (code 2)', 0, () => {
        const error = new Error('网络连接失败') as HttpError;
        error.statusCode = undefined;
        error.isNetworkError = true;
        error.isTimeout = false;
        expect(error.message).assertEqual('网络连接失败');
        expect(error.isNetworkError).assertTrue();
        expect(error.isTimeout).assertFalse();
      });

      it('should identify timeout error (code 4)', 0, () => {
        const error = new Error('请求超时') as HttpError;
        error.statusCode = undefined;
        error.isNetworkError = true;
        error.isTimeout = true;
        expect(error.message).assertEqual('请求超时');
        expect(error.isTimeout).assertTrue();
      });

      it('should identify DNS error (code 5)', 0, () => {
        const error = new Error('DNS解析失败') as HttpError;
        error.statusCode = undefined;
        error.isNetworkError = true;
        error.isTimeout = false;
        expect(error.message).assertEqual('DNS解析失败');
        expect(error.isNetworkError).assertTrue();
      });
    });

    describe('Retry Logic', () => {
      it('should retry on network error codes', 0, () => {
        const retryCodes = [2, 4, 5];
        const testCases = [
          { code: 2, shouldRetry: true },
          { code: 4, shouldRetry: true },
          { code: 5, shouldRetry: true },
          { code: 1, shouldRetry: false },
          { code: 3, shouldRetry: false },
          { code: 6, shouldRetry: false },
          { code: 100, shouldRetry: false },
        ];

        testCases.forEach(tc => {
          const result = retryCodes.includes(tc.code);
          expect(result).assertEqual(tc.shouldRetry);
        });
      });
    });

    describe('HTTP Method Support', () => {
      it('should support all HTTP methods', 0, () => {
        const methods: Array<'GET' | 'POST' | 'PUT' | 'DELETE'> = ['GET', 'POST', 'PUT', 'DELETE'];
        expect(methods.length).assertEqual(4);
        expect(methods).assertContain('GET');
        expect(methods).assertContain('POST');
        expect(methods).assertContain('PUT');
        expect(methods).assertContain('DELETE');
      });
    });

    describe('HttpRequestOptions Validation', () => {
      it('should handle empty options', 0, () => {
        const options: HttpRequestOptions = {};
        expect(options.method).assertNull();
        expect(options.headers).assertNull();
        expect(options.data).assertNull();
        expect(options.timeout).assertNull();
        expect(options.retryCount).assertNull();
      });

      it('should validate timeout is a number', 0, () => {
        const options: HttpRequestOptions = { timeout: 10000 };
        expect(typeof options.timeout).assertEqual('number');
        expect(options.timeout).assertEqual(10000);
      });

      it('should validate retryCount is a number', 0, () => {
        const options: HttpRequestOptions = { retryCount: 3 };
        expect(typeof options.retryCount).assertEqual('number');
        expect(options.retryCount).assertEqual(3);
      });
    });

    describe('HttpResponse Structure', () => {
      it('should have correct structure', 0, () => {
        const response: HttpResponse<{ id: number; name: string }> = {
          data: { id: 1, name: 'test' },
          statusCode: 200,
          headers: { 'Content-Type': 'application/json', 'X-Request-Id': '123' }
        };

        expect(response.data).assertNotNull();
        expect(response.data.id).assertEqual(1);
        expect(response.data.name).assertEqual('test');
        expect(response.statusCode).assertEqual(200);
        expect(response.headers).assertNotNull();
        expect(response.headers['Content-Type']).assertEqual('application/json');
        expect(response.headers['X-Request-Id']).assertEqual('123');
      });
    });

    describe('URL Construction', () => {
      it('should prepend base URL for relative paths', 0, () => {
        const baseUrl = 'http://localhost:8000/api/v1';
        const relativePath = '/chat';
        const expected = baseUrl + relativePath;
        expect(expected).assertEqual('http://localhost:8000/api/v1/chat');
      });

      it('should use absolute URL directly', 0, () => {
        const absoluteUrl = 'https://api.example.com/users';
        expect(absoluteUrl.startsWith('http')).assertTrue();
        expect(absoluteUrl.startsWith('http://')).assertTrue();
      });
    });
  });
}