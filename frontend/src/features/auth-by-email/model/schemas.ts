import { z } from 'zod';

export const signInSchema = z.object({
  email: z.string().email('Enter a valid email'),
  password: z.string().min(8, 'At least 8 characters').max(72),
});

export const signUpSchema = signInSchema.extend({
  name: z.string().min(1, 'Name is required').max(100),
});

export type SignInValues = z.infer<typeof signInSchema>;
export type SignUpValues = z.infer<typeof signUpSchema>;
