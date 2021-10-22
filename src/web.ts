import { WebPlugin } from '@capacitor/core';

import type { GesturePlugin } from './definitions';

export class GestureWeb extends WebPlugin implements GesturePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
