import { Link } from 'react-router';
import { Button } from '@/shared/ui';
import { PostFeed } from '@/widgets/post-feed';
import { useSession } from '@/entities/session';

export function PostsPage() {
  const { user } = useSession();
  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Posts</h1>
        {user && (
          <Link to="/posts/new">
            <Button>New post</Button>
          </Link>
        )}
      </div>
      <PostFeed />
    </div>
  );
}
