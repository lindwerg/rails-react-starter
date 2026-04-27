import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Button, Input, FormField } from '@/shared/ui';
import { toApiError } from '@/shared/api';
import { signUpSchema, type SignUpValues } from '../model/schemas';
import { useSignUpMutation } from '../model/useSignUpMutation';

type Props = {
  onSuccess?: () => void;
};

export function SignUpForm({ onSuccess }: Props) {
  const { register, handleSubmit, formState, setError } = useForm<SignUpValues>({
    resolver: zodResolver(signUpSchema),
  });
  const mutation = useSignUpMutation();

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
    <form onSubmit={onSubmit} className="flex flex-col gap-4" aria-label="sign-up-form">
      <FormField label="Name" htmlFor="name" error={formState.errors.name?.message}>
        <Input id="name" autoComplete="name" {...register('name')} />
      </FormField>
      <FormField label="Email" htmlFor="email" error={formState.errors.email?.message}>
        <Input id="email" type="email" autoComplete="email" {...register('email')} />
      </FormField>
      <FormField
        label="Password"
        htmlFor="password"
        error={formState.errors.password?.message}
        hint="Minimum 8 characters"
      >
        <Input id="password" type="password" autoComplete="new-password" {...register('password')} />
      </FormField>
      {formState.errors.root && (
        <p role="alert" className="text-sm text-red-600">
          {formState.errors.root.message}
        </p>
      )}
      <Button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating…' : 'Create account'}
      </Button>
    </form>
  );
}
