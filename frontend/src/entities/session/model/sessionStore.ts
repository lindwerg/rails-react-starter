import { create } from 'zustand';
import type { User } from '@/shared/api';

type State = {
  user: User | null;
  isLoading: boolean;
};

type Actions = {
  setUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
  reset: () => void;
};

export const useSessionStore = create<State & Actions>((set) => ({
  user: null,
  isLoading: true,
  setUser: (user) => set({ user, isLoading: false }),
  setLoading: (isLoading) => set({ isLoading }),
  reset: () => set({ user: null, isLoading: false }),
}));
