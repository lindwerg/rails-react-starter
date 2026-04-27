import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SignInForm } from './SignInForm';

function renderWithClient(ui: React.ReactNode) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(<QueryClientProvider client={qc}>{ui}</QueryClientProvider>);
}

describe('SignInForm', () => {
  it('shows validation errors on empty submit', async () => {
    renderWithClient(<SignInForm />);
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }));
    expect(await screen.findByText(/valid email/i)).toBeInTheDocument();
    expect(screen.getByText(/at least 8/i)).toBeInTheDocument();
  });

  it('calls onSuccess on successful sign-in', async () => {
    const onSuccess = vi.fn();
    renderWithClient(<SignInForm onSuccess={onSuccess} />);
    await userEvent.type(screen.getByLabelText(/email/i), 'demo@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'password123');
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }));
    await waitFor(() => expect(onSuccess).toHaveBeenCalled());
  });

  it('shows server error on bad password', async () => {
    renderWithClient(<SignInForm />);
    await userEvent.type(screen.getByLabelText(/email/i), 'demo@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'wrongpassword');
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }));
    expect(await screen.findByRole('alert')).toHaveTextContent(/invalid/i);
  });
});
