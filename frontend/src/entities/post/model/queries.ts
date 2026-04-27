import { useQuery } from '@tanstack/react-query';
import { fetchPosts, fetchPost } from '../api/postApi';

export const POSTS_KEYS = {
  all: ['posts'] as const,
  list: (page: number) => ['posts', 'list', page] as const,
  one: (id: number) => ['posts', 'one', id] as const,
};

export function usePostsQuery(page = 1) {
  return useQuery({
    queryKey: POSTS_KEYS.list(page),
    queryFn: () => fetchPosts(page),
  });
}

export function usePostQuery(id: number) {
  return useQuery({
    queryKey: POSTS_KEYS.one(id),
    queryFn: () => fetchPost(id),
    enabled: Number.isFinite(id) && id > 0,
  });
}
