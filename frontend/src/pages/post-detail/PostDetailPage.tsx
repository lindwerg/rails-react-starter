import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Button, Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import { usePostQuery } from '@/entities/post';
import { useSession } from '@/entities/session';
import { EditPostForm } from '@/features/edit-post';
import { DeletePostButton } from '@/features/delete-post';

export function PostDetailPage() {
  const { id } = useParams<{ id: string }>();
  const postId = Number(id);
  const { data: post, isLoading, isError } = usePostQuery(postId);
  const { user } = useSession();
  const navigate = useNavigate();
  const [isEditing, setIsEditing] = useState(false);

  if (isLoading) return <p className="py-6 text-neutral-500">Loading…</p>;
  if (isError || !post) return <p className="py-6 text-red-600">Post not found.</p>;

  const isOwner = user?.id === post.authorId;

  return (
    <div className="flex flex-col gap-4 py-4">
      <Card>
        {!isEditing ? (
          <>
            <CardHeader>
              <CardTitle>{post.title}</CardTitle>
              <p className="text-xs text-neutral-500">
                {post.published ? 'Published' : 'Draft'} ·{' '}
                {new Date(post.createdAt).toLocaleString()}
              </p>
            </CardHeader>
            <CardContent>
              <p className="whitespace-pre-line">{post.body}</p>
              {isOwner && (
                <div className="mt-4 flex gap-2">
                  <Button variant="outline" size="sm" onClick={() => setIsEditing(true)}>
                    Edit
                  </Button>
                  <DeletePostButton postId={post.id} onDeleted={() => navigate('/posts')} />
                </div>
              )}
            </CardContent>
          </>
        ) : (
          <>
            <CardHeader>
              <CardTitle>Edit post</CardTitle>
            </CardHeader>
            <CardContent>
              <EditPostForm post={post} onSaved={() => setIsEditing(false)} />
            </CardContent>
          </>
        )}
      </Card>
    </div>
  );
}
