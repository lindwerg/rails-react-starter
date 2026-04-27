import { test, expect } from '@playwright/test';

test('logged-in user can create, edit, delete a post', async ({ page }) => {
  const email = `author_${Date.now()}@example.com`;

  // Sign up
  await page.goto('/sign-up');
  await page.getByLabel('Name').fill('Author');
  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password').fill('password1234');
  await page.getByRole('button', { name: /create account/i }).click();
  await expect(page).toHaveURL('/');

  // Create
  await page.goto('/posts/new');
  await page.getByLabel('Title').fill('My Post');
  await page.getByLabel('Body').fill('Hello world from Playwright.');
  await page.getByLabel(/publish immediately/i).check();
  await page.getByRole('button', { name: /save post/i }).click();
  await expect(page.getByRole('heading', { name: 'My Post' })).toBeVisible();

  // Edit
  await page.getByRole('button', { name: /edit/i }).click();
  await page.getByLabel('Title').fill('My Post (edited)');
  await page.getByRole('button', { name: /^save$/i }).click();
  await expect(page.getByRole('heading', { name: 'My Post (edited)' })).toBeVisible();

  // Delete
  page.on('dialog', (d) => d.accept());
  await page.getByRole('button', { name: /delete/i }).click();
  await expect(page).toHaveURL('/posts');
  await expect(page.getByText('My Post (edited)')).not.toBeVisible();
});
