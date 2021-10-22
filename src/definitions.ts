export interface GesturePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
