import { z } from 'zod';

export const postSchema = z.object({
  title: z.string().min(1, 'Title is required').max(200),
  body: z.string().min(1, 'Body is required').max(50_000),
  publish: z.boolean().optional(),
});

export type PostFormValues = z.infer<typeof postSchema>;
