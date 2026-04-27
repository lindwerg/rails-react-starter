import ky, { HTTPError } from 'ky';
import { env } from '@/shared/config';

export const http = ky.create({
  prefixUrl: `${env.apiBaseUrl}/api/v1`,
  credentials: 'include',
  retry: { limit: 1, methods: ['get'], statusCodes: [502, 503, 504] },
  timeout: 15_000,
  hooks: {
    beforeRequest: [
      (request) => {
        request.headers.set('Accept', 'application/json');
      },
    ],
  },
});

export type ApiError = {
  status: number;
  code?: string;
  message: string;
};

export async function toApiError(error: unknown): Promise<ApiError> {
  if (error instanceof HTTPError) {
    let body: { code?: string; error?: string } = {};
    try {
      body = (await error.response.clone().json()) as typeof body;
    } catch {
      // ignore JSON parse errors
    }
    return {
      status: error.response.status,
      ...(body.code !== undefined && { code: body.code }),
      message: body.error ?? error.message,
    };
  }
  return { status: 0, message: error instanceof Error ? error.message : 'Unknown error' };
}
