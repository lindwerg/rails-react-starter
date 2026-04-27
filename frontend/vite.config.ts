import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'node:path';

const env = process.env;
const frontendPort = Number(env.FRONTEND_PORT ?? env.VITE_PORT ?? 5173);
const backendPort = Number(env.BACKEND_PORT ?? 3000);
const apiTarget = env.VITE_API_BASE_URL ?? `http://localhost:${backendPort}`;

export default defineConfig({
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
});
