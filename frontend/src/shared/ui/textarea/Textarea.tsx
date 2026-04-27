import { forwardRef, type TextareaHTMLAttributes } from 'react';
import { cn } from '@/shared/lib';

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaHTMLAttributes<HTMLTextAreaElement>>(
  ({ className, ...props }, ref) => (
    <textarea
      ref={ref}
      className={cn(
        'flex min-h-24 w-full rounded-md border border-neutral-300 bg-white px-3 py-2 text-sm',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-500',
        'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      {...props}
    />
  ),
);
Textarea.displayName = 'Textarea';
