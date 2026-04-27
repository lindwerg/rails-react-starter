import { http } from '@/shared/api';
import type { Post } from '@/shared/api';
import type { PostFormValues } from '@/features/create-post';

export const updatePost = (id: number, values: PostFormValues) =>
  http.patch(`posts/${id}`, { json: { post: values } }).json<Post>();
