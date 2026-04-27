import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Button } from '@/shared/ui';
import { POSTS_KEYS } from '@/entities/post';
import { deletePost } from '../api/deletePost';

type Props = { postId: number; onDeleted?: () => void };

export function DeletePostButton({ postId, onDeleted }: Props) {
  const qc = useQueryClient();
  const mutation = useMutation({
    mutationFn: () => deletePost(postId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: POSTS_KEYS.all });
      onDeleted?.();
    },
  });

  return (
    <Button
      type="button"
      variant="destructive"
      size="sm"
      disabled={mutation.isPending}
      onClick={() => {
        if (window.confirm('Delete this post?')) mutation.mutate();
      }}
    >
      {mutation.isPending ? 'Deleting…' : 'Delete'}
    </Button>
  );
}
