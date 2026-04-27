import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button, Input, Textarea, FormField } from '@/shared/ui';
import { toApiError } from '@/shared/api';
import { postSchema, type PostFormValues } from '../model/schema';
import { useCreatePostMutation } from '../model/useCreatePostMutation';

type Props = { onCreated?: (id: number) => void };

export function CreatePostForm({ onCreated }: Props) {
  const { register, handleSubmit, formState, setError } = useForm<PostFormValues>({
    resolver: zodResolver(postSchema),
    defaultValues: { title: '', body: '', publish: false },
  });
  const mutation = useCreatePostMutation();

  const onSubmit = handleSubmit(async (values) => {
    try {
      const post = await mutation.mutateAsync(values);
      onCreated?.(post.id);
    } catch (e) {
      const apiError = await toApiError(e);
      setError('root', { message: apiError.message });
    }
  });

  return (
    <form onSubmit={onSubmit} aria-label="create-post-form" className="flex flex-col gap-4">
      <FormField label="Title" htmlFor="title" error={formState.errors.title?.message}>
        <Input id="title" {...register('title')} />
      </FormField>
      <FormField label="Body" htmlFor="body" error={formState.errors.body?.message}>
        <Textarea id="body" rows={8} {...register('body')} />
      </FormField>
      <label className="flex items-center gap-2 text-sm">
        <input type="checkbox" {...register('publish')} /> Publish immediately
      </label>
      {formState.errors.root && (
        <p role="alert" className="text-sm text-red-600">
          {formState.errors.root.message}
        </p>
      )}
      <Button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Saving…' : 'Save post'}
      </Button>
    </form>
  );
}
