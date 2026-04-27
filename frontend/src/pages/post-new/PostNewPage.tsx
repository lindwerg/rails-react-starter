import { useNavigate } from 'react-router';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import { CreatePostForm } from '@/features/create-post';

export function PostNewPage() {
  const navigate = useNavigate();
  return (
    <div className="py-6">
      <Card>
        <CardHeader>
          <CardTitle>New post</CardTitle>
        </CardHeader>
        <CardContent>
          <CreatePostForm onCreated={(id) => navigate(`/posts/${id}`)} />
        </CardContent>
      </Card>
    </div>
  );
}
