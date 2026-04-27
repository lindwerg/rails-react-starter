import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config';

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: ['./vitest.setup.ts'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'json-summary', 'html'],
        thresholds: { lines: 80, statements: 80, branches: 75, functions: 80 },
        exclude: [
          '**/*.stories.tsx',
          '**/*.config.*',
          '**/index.ts',
          'src/main.tsx',
          'src/app/**',
          'src/shared/api/types.gen.ts',
        ],
      },
    },
  }),
);
