import { useMutation, useQueryClient } from '@tanstack/react-query';
import { POSTS_KEYS } from '@/entities/post';
import { createPost } from '../api/createPost';

export function useCreatePostMutation() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: createPost,
    onSuccess: () => qc.invalidateQueries({ queryKey: POSTS_KEYS.all }),
  });
}
