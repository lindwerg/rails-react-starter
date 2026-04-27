import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button, Input, FormField } from '@/shared/ui';
import { toApiError } from '@/shared/api';
import { signInSchema, type SignInValues } from '../model/schemas';
import { useSignInMutation } from '../model/useSignInMutation';

type Props = {
  onSuccess?: () => void;
};

export function SignInForm({ onSuccess }: Props) {
  const { register, handleSubmit, formState, setError } = useForm<SignInValues>({
    resolver: zodResolver(signInSchema),
  });
  const mutation = useSignInMutation();

  const onSubmit = handleSubmit(async (values) => {
    try {
      await mutation.mutateAsync(values);
      onSuccess?.();
    } catch (e) {
      const apiError = await toApiError(e);
      setError('root', { message: apiError.message });
    }
  });

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-4" aria-label="sign-in-form">
      <FormField label="Email" htmlFor="email" error={formState.errors.email?.message}>
        <Input id="email" type="email" autoComplete="email" {...register('email')} />
      </FormField>
      <FormField label="Password" htmlFor="password" error={formState.errors.password?.message}>
        <Input
          id="password"
          type="password"
          autoComplete="current-password"
          {...register('password')}
        />
      </FormField>
      {formState.errors.root && (
        <p role="alert" className="text-sm text-red-600">
          {formState.errors.root.message}
        </p>
      )}
      <Button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Signing in…' : 'Sign in'}
      </Button>
    </form>
  );
}
