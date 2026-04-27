import { http } from '@/shared/api';
import type { User } from '@/shared/api';

export async function fetchCurrentUser(): Promise<User | null> {
  try {
    return await http.get('me').json<User>();
  } catch {
    return null;
  }
}
