import { registerPlugin } from '@capacitor/core';

import type { GesturePlugin } from './definitions';

const Gesture = registerPlugin<GesturePlugin>('Gesture', {
  web: () => import('./web').then(m => new m.GestureWeb()),
});

export * from './definitions';
export { Gesture };
