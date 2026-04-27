import { http } from '@/shared/api';

export const deletePost = (id: number) => http.delete(`posts/${id}`);
