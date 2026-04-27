import { useEffect } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { http } from '@/shared/api';
import { fetchCurrentUser } from '@/entities/user';
import { useSessionStore } from './sessionStore';

export const SESSION_QUERY_KEY = ['session', 'me'] as const;

export function useSession() {
  const { user, isLoading, setUser, reset } = useSessionStore();
  const qc = useQueryClient();

  const query = useQuery({
    queryKey: SESSION_QUERY_KEY,
    queryFn: fetchCurrentUser,
    staleTime: 60_000,
  });

  useEffect(() => {
    if (query.isSuccess) setUser(query.data ?? null);
    if (query.isError) reset();
  }, [query.isSuccess, query.isError, query.data, setUser, reset]);

  async function signOut() {
    await http.delete('auth/sign_out').catch(() => undefined);
    reset();
    qc.removeQueries({ queryKey: SESSION_QUERY_KEY });
  }

  return {
    user,
    isLoading: isLoading || query.isLoading,
    signOut,
    refresh: () => qc.invalidateQueries({ queryKey: SESSION_QUERY_KEY }),
  };
}
