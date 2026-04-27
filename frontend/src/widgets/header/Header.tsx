import { Link, useNavigate } from 'react-router';
import { useSession } from '@/entities/session';
import { Button } from '@/shared/ui';

export function Header() {
  const { user, signOut } = useSession();
  const navigate = useNavigate();

  return (
    <header className="border-b border-neutral-200 bg-white">
      <div className="mx-auto flex max-w-3xl items-center justify-between p-3">
        <Link to="/" className="text-base font-semibold tracking-tight">
          Starter
        </Link>
        <nav className="flex items-center gap-2 text-sm">
          <Link to="/posts" className="text-neutral-700 hover:text-black">
            Posts
          </Link>
          {user ? (
            <>
              <Link to="/posts/new" className="text-neutral-700 hover:text-black">
                New post
              </Link>
              <span className="text-neutral-500">{user.email}</span>
              <Button
                size="sm"
                variant="outline"
                onClick={async () => {
                  await signOut();
                  navigate('/');
                }}
              >
                Sign out
              </Button>
            </>
          ) : (
            <>
              <Link to="/sign-in">
                <Button size="sm" variant="outline">
                  Sign in
                </Button>
              </Link>
              <Link to="/sign-up">
                <Button size="sm">Sign up</Button>
              </Link>
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
