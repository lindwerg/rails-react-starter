import { test, expect } from '@playwright/test';

test.describe('Auth flow', () => {
  test('sign-up → see authenticated header → sign-out', async ({ page }) => {
    const email = `user_${Date.now()}@example.com`;

    await page.goto('/sign-up');
    await page.getByLabel('Name').fill('E2E User');
    await page.getByLabel('Email').fill(email);
    await page.getByLabel('Password').fill('password1234');
    await page.getByRole('button', { name: /create account/i }).click();

    await expect(page).toHaveURL('/');
    await expect(page.getByText(email)).toBeVisible();

    await page.getByRole('button', { name: /sign out/i }).click();
    await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
  });

  test('sign-in with bad credentials shows error', async ({ page }) => {
    await page.goto('/sign-in');
    await page.getByLabel('Email').fill('nobody@example.com');
    await page.getByLabel('Password').fill('wrongpassword');
    await page.getByRole('button', { name: /sign in/i }).click();
    await expect(page.getByRole('alert')).toBeVisible();
  });
});
