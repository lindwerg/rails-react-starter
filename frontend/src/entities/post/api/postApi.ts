import { http } from '@/shared/api';
import type { Post, Paginated } from '@/shared/api';

export const fetchPosts = (page = 1) =>
  http.get('posts', { searchParams: { page } }).json<Paginated<Post>>();

export const fetchPost = (id: number) => http.get(`posts/${id}`).json<Post>();
