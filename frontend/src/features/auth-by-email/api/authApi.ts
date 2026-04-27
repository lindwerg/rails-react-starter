import { http } from '@/shared/api';
import type { AuthResponse } from '@/shared/api';
import type { SignInValues, SignUpValues } from '../model/schemas';

export const signIn = (values: SignInValues) =>
  http.post('auth/sign_in', { json: values }).json<AuthResponse>();

export const signUp = (values: SignUpValues) =>
  http.post('auth/sign_up', { json: values }).json<AuthResponse>();
