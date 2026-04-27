import { Link } from 'react-router';
import { Button, Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';

export function HomePage() {
  return (
    <div className="flex flex-col gap-6 py-6">
      <Card>
        <CardHeader>
          <CardTitle>Welcome to the starter</CardTitle>
        </CardHeader>
        <CardContent>
          A Rails 8 + React 19 monorepo with FSD on the frontend, Packwerk modular monolith on the
          backend, JWT auth (httpOnly cookies), and a TDD-first workflow.
        </CardContent>
      </Card>
      <div className="flex gap-2">
        <Link to="/posts">
          <Button>Browse posts</Button>
        </Link>
        <Link to="/sign-up">
          <Button variant="outline">Create account</Button>
        </Link>
      </div>
    </div>
  );
}
