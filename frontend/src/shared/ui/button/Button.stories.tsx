import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'shared/ui/Button',
  component: Button,
  args: { children: 'Click me' },
};
export default meta;

type Story = StoryObj<typeof Button>;

export const Default: Story = {};
export const Outline: Story = { args: { variant: 'outline' } };
export const Destructive: Story = { args: { variant: 'destructive' } };
