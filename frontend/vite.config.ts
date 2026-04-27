import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'node:path';

export default defineConfig(({ mode }) => {
  // Load .env (and .env.<mode>) from the repo root and from frontend/.
  const repoRootEnv = loadEnv(mode, path.resolve(__dirname, '..'), '');
  const localEnv = loadEnv(mode, __dirname, '');
  const env = { ...repoRootEnv, ...localEnv, ...process.env } as Record<string, string | undefined>;

  const frontendPort = Number(env.FRONTEND_PORT ?? env.VITE_PORT ?? 5173);
  const backendPort = Number(env.BACKEND_PORT ?? 3000);
  const apiTarget = env.VITE_API_BASE_URL ?? `http://localhost:${backendPort}`;

  return {
    plugins: [react(), tailwindcss()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
    server: {
      port: frontendPort,
      host: true,
      strictPort: false,
      proxy: {
        '/api': {
          target: apiTarget,
          changeOrigin: true,
          secure: false,
        },
      },
    },
    build: {
      target: 'es2022',
      sourcemap: true,
    },
  };
});
