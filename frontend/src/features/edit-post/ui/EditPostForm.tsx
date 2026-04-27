import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Button, Input, Textarea, FormField } from '@/shared/ui';
import { toApiError, type Post } from '@/shared/api';
import { POSTS_KEYS } from '@/entities/post';
import { postSchema, type PostFormValues } from '@/features/create-post';
import { updatePost } from '../api/updatePost';

type Props = {
  post: Post;
  onSaved?: () => void;
};

export function EditPostForm({ post, onSaved }: Props) {
  const qc = useQueryClient();
  const { register, handleSubmit, formState, setError } = useForm<PostFormValues>({
    resolver: zodResolver(postSchema),
    defaultValues: { title: post.title, body: post.body, publish: post.published },
  });

  const mutation = useMutation({
    mutationFn: (v: PostFormValues) => updatePost(post.id, v),
    onSuccess: () => qc.invalidateQueries({ queryKey: POSTS_KEYS.all }),
  });

  const onSubmit = handleSubmit(async (values) => {
    try {
      await mutation.mutateAsync(values);
      onSaved?.();
    } catch (e) {
      const apiError = await toApiError(e);
      setError('root', { message: apiError.message });
    }
  });

  return (
    <form onSubmit={onSubmit} aria-label="edit-post-form" className="flex flex-col gap-4">
      <FormField label="Title" htmlFor="title" error={formState.errors.title?.message}>
        <Input id="title" {...register('title')} />
      </FormField>
      <FormField label="Body" htmlFor="body" error={formState.errors.body?.message}>
        <Textarea id="body" rows={8} {...register('body')} />
      </FormField>
      <label className="flex items-center gap-2 text-sm">
        <input type="checkbox" {...register('publish')} /> Published
      </label>
      {formState.errors.root && (
        <p role="alert" className="text-sm text-red-600">
          {formState.errors.root.message}
        </p>
      )}
      <Button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Saving…' : 'Save'}
      </Button>
    </form>
  );
}
