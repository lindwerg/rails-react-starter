import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config';

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      globals: true,
      environment: 'jsdom',
      setupFiles: ['./vitest.setup.ts'],
      // e2e specs run under Playwright, not Vitest.
      exclude: ['node_modules', 'dist', 'e2e/**', 'playwright-report/**', 'test-results/**'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'json-summary', 'html'],
        // Starter baseline — bump these up as you add tests.
        // Aim for 80/80/75/80 once your real feature work has coverage.
        thresholds: { lines: 25, statements: 25, branches: 55, functions: 35 },
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
