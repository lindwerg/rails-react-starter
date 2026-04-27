import { type ReactNode } from 'react';
import { Label } from '@/shared/ui/label';
import { cn } from '@/shared/lib';

type Props = {
  label: string;
  htmlFor?: string;
  error?: string | undefined;
  hint?: string;
  className?: string;
  children: ReactNode;
};

export function FormField({ label, htmlFor, error, hint, className, children }: Props) {
  return (
    <div className={cn('flex flex-col gap-1', className)}>
      <Label htmlFor={htmlFor}>{label}</Label>
      {children}
      {hint && !error && <p className="text-xs text-neutral-500">{hint}</p>}
      {error && (
        <p role="alert" className="text-xs text-red-600">
          {error}
        </p>
      )}
    </div>
  );
}
