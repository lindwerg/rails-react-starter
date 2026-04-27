import { BrowserRouter, Routes, Route } from 'react-router';
import { HomePage } from '@/pages/home';
import { SignInPage } from '@/pages/sign-in';
import { SignUpPage } from '@/pages/sign-up';
import { PostsPage } from '@/pages/posts';
import { PostDetailPage } from '@/pages/post-detail';
import { PostNewPage } from '@/pages/post-new';
import { NotFoundPage } from '@/pages/not-found';
import { Header } from '@/widgets/header';
import { RequireAuth } from './RequireAuth';

export function AppRouter() {
  return (
    <BrowserRouter>
      <Header />
      <main className="mx-auto max-w-3xl p-4">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/sign-in" element={<SignInPage />} />
          <Route path="/sign-up" element={<SignUpPage />} />
          <Route path="/posts" element={<PostsPage />} />
          <Route path="/posts/:id" element={<PostDetailPage />} />
          <Route
            path="/posts/new"
            element={
              <RequireAuth>
                <PostNewPage />
              </RequireAuth>
            }
          />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </main>
    </BrowserRouter>
  );
}
