import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import react from 'eslint-plugin-react';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import tseslint from 'typescript-eslint';
import boundaries from 'eslint-plugin-boundaries';
import storybook from 'eslint-plugin-storybook';

const FSD_LAYERS = ['app', 'pages', 'widgets', 'features', 'entities', 'shared'];

export default tseslint.config(
  { ignores: ['dist', 'storybook-static', 'node_modules', 'src/shared/api/types.gen.ts'] },
  // Node-side configs (vite, vitest) — they live in tsconfig.node.json.
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ['vite.config.ts', 'vitest.config.ts'],
    languageOptions: {
      ecmaVersion: 2022,
      globals: globals.node,
      parserOptions: { project: ['./tsconfig.node.json'] },
    },
  },
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ['src/**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2022,
      globals: globals.browser,
      parserOptions: { project: ['./tsconfig.app.json'] },
    },
    plugins: {
      'react-hooks': reactHooks,
      react,
      'jsx-a11y': jsxA11y,
      boundaries,
    },
    settings: {
      react: { version: 'detect' },
      'boundaries/elements': FSD_LAYERS.map((layer) => ({
        type: layer,
        pattern: `src/${layer}/*`,
      })),
      'boundaries/include': ['src/**/*'],
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      ...jsxA11y.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
      // FSD: a layer can only import from layers strictly below it
      'boundaries/element-types': [
        'error',
        {
          default: 'disallow',
          rules: [
            { from: 'app', allow: ['pages', 'widgets', 'features', 'entities', 'shared'] },
            { from: 'pages', allow: ['widgets', 'features', 'entities', 'shared'] },
            { from: 'widgets', allow: ['features', 'entities', 'shared'] },
            { from: 'features', allow: ['entities', 'shared'] },
            { from: 'entities', allow: ['shared'] },
            { from: 'shared', allow: ['shared'] },
          ],
        },
      ],
      // No deep imports — only via slice public API (index.ts)
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['@/{app,pages,widgets,features,entities}/*/*'],
              message: 'Import only from the slice public API (index.ts), not deep paths.',
            },
          ],
        },
      ],
    },
  },
  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}', 'vitest.setup.ts'],
    languageOptions: { globals: { ...globals.browser, ...globals.node } },
    rules: {
      'boundaries/element-types': 'off',
      'no-restricted-imports': 'off',
    },
  },
  ...storybook.configs['flat/recommended'],
);
