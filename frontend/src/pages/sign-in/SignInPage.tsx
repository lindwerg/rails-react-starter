import { Link, useNavigate } from 'react-router';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import { SignInForm } from '@/features/auth-by-email';

export function SignInPage() {
  const navigate = useNavigate();
  return (
    <div className="mx-auto max-w-sm py-8">
      <Card>
        <CardHeader>
          <CardTitle>Sign in</CardTitle>
        </CardHeader>
        <CardContent>
          <SignInForm onSuccess={() => navigate('/')} />
          <p className="mt-4 text-sm text-neutral-600">
            No account?{' '}
            <Link to="/sign-up" className="text-brand-600 underline">
              Create one
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
