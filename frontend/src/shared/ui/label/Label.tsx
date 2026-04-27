import { forwardRef, type LabelHTMLAttributes } from 'react';
import { cn } from '@/shared/lib';

export const Label = forwardRef<HTMLLabelElement, LabelHTMLAttributes<HTMLLabelElement>>(
  ({ className, children, ...props }, ref) => (
    <label ref={ref} className={cn('text-sm font-medium text-neutral-800', className)} {...props}>
      {children}
    </label>
  ),
);
Label.displayName = 'Label';
