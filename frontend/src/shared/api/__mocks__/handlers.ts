import { http, HttpResponse } from 'msw';
import { env } from '@/shared/config';

const apiUrl = (path: string) => `${env.apiBaseUrl}/api/v1${path}`;

export const handlers = [
  http.post(apiUrl('/auth/sign_up'), async ({ request }) => {
    const body = (await request.json()) as { email: string; password: string; name?: string };
    return HttpResponse.json(
      {
        user: {
          id: 1,
          email: body.email,
          name: body.name ?? '',
          createdAt: new Date().toISOString(),
        },
        token: 'fake-jwt',
      },
      { status: 201 },
    );
  }),

  http.post(apiUrl('/auth/sign_in'), async ({ request }) => {
    const body = (await request.json()) as { email: string; password: string };
    if (body.password === 'password123') {
      return HttpResponse.json(
        {
          user: { id: 1, email: body.email, name: 'Demo', createdAt: new Date().toISOString() },
          token: 'fake-jwt',
        },
        { status: 201 },
      );
    }
    return HttpResponse.json(
      { error: 'Invalid email or password', code: 'invalid_credentials' },
      { status: 401 },
    );
  }),

  http.delete(apiUrl('/auth/sign_out'), () => new HttpResponse(null, { status: 204 })),

  http.get(apiUrl('/me'), () =>
    HttpResponse.json({
      id: 1,
      email: 'demo@example.com',
      name: 'Demo',
      createdAt: new Date().toISOString(),
    }),
  ),

  http.get(apiUrl('/posts'), () =>
    HttpResponse.json({
      data: [
        {
          id: 1,
          title: 'Hello world',
          body: 'First post',
          publishedAt: new Date().toISOString(),
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          published: true,
          authorId: 1,
        },
      ],
      meta: { page: 1, pages: 1, count: 1, items: 20 },
    }),
  ),
];
