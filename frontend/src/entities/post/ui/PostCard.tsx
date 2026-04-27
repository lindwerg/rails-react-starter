import { Link } from 'react-router';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import type { Post } from '../model/types';

export function PostCard({ post, actions }: { post: Post; actions?: React.ReactNode }) {
  return (
    <Card>
      <CardHeader>
        <Link to={`/posts/${post.id}`} className="hover:underline">
          <CardTitle>{post.title}</CardTitle>
        </Link>
        <p className="text-xs text-neutral-500">
          {post.published ? 'Published' : 'Draft'} ·{' '}
          {new Date(post.createdAt).toLocaleString()}
        </p>
      </CardHeader>
      <CardContent>
        <p className="line-clamp-3 whitespace-pre-line">{post.body}</p>
        {actions && <div className="mt-3 flex gap-2">{actions}</div>}
      </CardContent>
    </Card>
  );
}
