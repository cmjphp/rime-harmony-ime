declare module 'librime_bridge.so' {
  import { RimeNativeModule, RimeStatus } from './RimeNativeBridge';

  export function init(userDir: string, sharedDataDir: string): boolean;
  export function processKey(keyCode: number, modifier: number): boolean;
  export function getComposition(): string;
  export function getCandidates(): string[];
  export function commitCandidate(index: number): string;
  export function clearComposition(): void;
  export function deploy(): boolean;
  export function getStatus(): RimeStatus;

  const bridge: RimeNativeModule;
  export default bridge;
}
