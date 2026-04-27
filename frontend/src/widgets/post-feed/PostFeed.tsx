import { useState } from 'react';
import { PostCard, usePostsQuery } from '@/entities/post';
import { Button } from '@/shared/ui';
import { useSession } from '@/entities/session';
import { DeletePostButton } from '@/features/delete-post';
import { Link } from 'react-router';

export function PostFeed() {
  const [page, setPage] = useState(1);
  const { user } = useSession();
  const { data, isLoading, isError } = usePostsQuery(page);

  if (isLoading) return <p className="text-neutral-500">Loading…</p>;
  if (isError || !data) return <p className="text-red-600">Failed to load posts.</p>;

  return (
    <div className="flex flex-col gap-4">
      {data.data.length === 0 && <p className="text-neutral-500">No posts yet.</p>}
      {data.data.map((post) => (
        <PostCard
          key={post.id}
          post={post}
          actions={
            user && user.id === post.authorId ? (
              <>
                <Link to={`/posts/${post.id}`}>
                  <Button size="sm" variant="outline">
                    Edit
                  </Button>
                </Link>
                <DeletePostButton postId={post.id} />
              </>
            ) : null
          }
        />
      ))}

      {data.meta.pages > 1 && (
        <div className="flex items-center justify-between pt-2 text-sm">
          <Button
            size="sm"
            variant="outline"
            disabled={page <= 1}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            ← Prev
          </Button>
          <span className="text-neutral-500">
            Page {data.meta.page} / {data.meta.pages}
          </span>
          <Button
            size="sm"
            variant="outline"
            disabled={page >= data.meta.pages}
            onClick={() => setPage((p) => p + 1)}
          >
            Next →
          </Button>
        </div>
      )}
    </div>
  );
}
