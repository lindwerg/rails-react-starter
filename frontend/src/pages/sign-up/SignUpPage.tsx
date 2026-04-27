import { Link, useNavigate } from 'react-router';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui';
import { SignUpForm } from '@/features/auth-by-email';

export function SignUpPage() {
  const navigate = useNavigate();
  return (
    <div className="mx-auto max-w-sm py-8">
      <Card>
        <CardHeader>
          <CardTitle>Create account</CardTitle>
        </CardHeader>
        <CardContent>
          <SignUpForm onSuccess={() => navigate('/')} />
          <p className="mt-4 text-sm text-neutral-600">
            Already have one?{' '}
            <Link to="/sign-in" className="text-brand-600 underline">
              Sign in
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
