import { type ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router';
import { useSession } from '@/entities/session';

export function RequireAuth({ children }: { children: ReactNode }) {
  const { user, isLoading } = useSession();
  const location = useLocation();

  if (isLoading) return <div className="p-6 text-sm text-neutral-500">Checking session…</div>;
  if (!user) return <Navigate to="/sign-in" state={{ from: location }} replace />;
  return <>{children}</>;
}
