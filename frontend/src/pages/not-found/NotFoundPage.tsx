import { Link } from 'react-router';

export function NotFoundPage() {
  return (
    <div className="flex flex-col gap-3 py-12 text-center">
      <h1 className="text-2xl font-semibold">404 — Not found</h1>
      <p className="text-neutral-600">The page you’re looking for doesn’t exist.</p>
      <Link to="/" className="text-brand-600 underline">
        Back to home
      </Link>
    </div>
  );
}
