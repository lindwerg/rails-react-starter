import { http } from '@/shared/api';
import type { Post } from '@/shared/api';
import type { PostFormValues } from '../model/schema';

export const createPost = (values: PostFormValues) =>
  http.post('posts', { json: { post: values } }).json<Post>();
