import { useMutation, useQueryClient } from '@tanstack/react-query';
import { toApiError } from '@/shared/api';
import { SESSION_QUERY_KEY } from '@/entities/session';
import { signUp } from '../api/authApi';

export function useSignUpMutation() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: signUp,
    onSuccess: (data) => qc.setQueryData(SESSION_QUERY_KEY, data.user),
    onError: async (e) => toApiError(e),
  });
}
