import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { PostCard } from './PostCard';
import type { Post } from '../model/types';

const post: Post = {
  id: 1,
  title: 'Hello',
  body: 'World',
  publishedAt: new Date().toISOString(),
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  published: true,
  authorId: 1,
};

describe('PostCard', () => {
  it('renders title and body', () => {
    render(
      <MemoryRouter>
        <PostCard post={post} />
      </MemoryRouter>,
    );
    expect(screen.getByRole('heading', { name: 'Hello' })).toBeInTheDocument();
    expect(screen.getByText('World')).toBeInTheDocument();
  });

  it('marks drafts as Draft', () => {
    render(
      <MemoryRouter>
        <PostCard post={{ ...post, published: false, publishedAt: null }} />
      </MemoryRouter>,
    );
    expect(screen.getByText(/Draft/)).toBeInTheDocument();
  });
});
