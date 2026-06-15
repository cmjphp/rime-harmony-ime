export class RimeStatus {
  ready: boolean;
  nativeLoaded: boolean;
  engine: string;
  compositionLength: number;

  constructor(ready: boolean, nativeLoaded: boolean, engine: string, compositionLength: number) {
    this.ready = ready;
    this.nativeLoaded = nativeLoaded;
    this.engine = engine;
    this.compositionLength = compositionLength;
  }
}

export interface RimeNativeModule {
  init(userDir: string, sharedDataDir: string): boolean;
  processKey(keyCode: number, modifier: number): boolean;
  getComposition(): string;
  getCandidates(): string[];
  commitCandidate(index: number): string;
  clearComposition(): void;
  setOption(option: string, value: boolean): boolean;
  deploy(): boolean;
  getStatus(): RimeStatus;
}

interface RimeNativeModuleLoader {
  default?: RimeNativeModule;
  init?: (userDir: string, sharedDataDir: string) => boolean;
  processKey?: (keyCode: number, modifier: number) => boolean;
  getComposition?: () => string;
  getCandidates?: () => string[];
  commitCandidate?: (index: number) => string;
  clearComposition?: () => void;
  setOption?: (option: string, value: boolean) => boolean;
  deploy?: () => boolean;
  getStatus?: () => RimeStatus;
}

class ArkTsMockRimeEngine implements RimeNativeModule {
  private composition: string = '';
  private ready: boolean = false;
  private simplification: boolean = true;

  init(userDir: string, sharedDataDir: string): boolean {
    this.ready = userDir.length > 0 && sharedDataDir.length > 0;
    return true;
  }

  processKey(keyCode: number, modifier: number): boolean {
    const char = String.fromCharCode(keyCode).toLowerCase();
    if (char >= 'a' && char <= 'z') {
      this.composition += char;
      return true;
    }
    return false;
  }

  getComposition(): string {
    return this.composition;
  }

  getCandidates(): string[] {
    return [];
  }

  commitCandidate(index: number): string {
    const candidates = this.getCandidates();
    let value = this.composition;
    if (index >= 0 && index < candidates.length) {
      value = candidates[index];
    }
    this.clearComposition();
    return value;
  }

  clearComposition(): void {
    this.composition = '';
  }

  setOption(option: string, value: boolean): boolean {
    if (option !== 'simplification') {
      return false;
    }
    this.simplification = value;
    return true;
  }

  deploy(): boolean {
    return true;
  }

  getStatus(): RimeStatus {
    return new RimeStatus(this.ready, false, this.simplification ? 'arkts-mock/simp' : 'arkts-mock/trad', this.composition.length);
  }
}

class RimeNativeBridgeImpl {
  private engine: RimeNativeModule = new ArkTsMockRimeEngine();
  private nativeLoaded: boolean = false;

  async init(userDir: string, sharedDataDir: string): Promise<boolean> {
    await this.tryLoadNative();
    try {
      return this.engine.init(userDir, sharedDataDir);
    } catch (err) {
      console.error(`Rime init failed, fallback to ArkTS mock: ${JSON.stringify(err)}`);
      this.engine = new ArkTsMockRimeEngine();
      this.nativeLoaded = false;
      return this.engine.init(userDir, sharedDataDir);
    }
  }

  processKey(keyCode: number, modifier: number): boolean {
    try {
      return this.engine.processKey(keyCode, modifier);
    } catch (err) {
      console.error(`processKey failed: ${JSON.stringify(err)}`);
      return false;
    }
  }

  getComposition(): string {
    try {
      return this.engine.getComposition();
    } catch (err) {
      console.error(`getComposition failed: ${JSON.stringify(err)}`);
      return '';
    }
  }

  getCandidates(): string[] {
    try {
      return this.engine.getCandidates();
    } catch (err) {
      console.error(`getCandidates failed: ${JSON.stringify(err)}`);
      return [];
    }
  }

  commitCandidate(index: number): string {
    try {
      return this.engine.commitCandidate(index);
    } catch (err) {
      console.error(`commitCandidate failed: ${JSON.stringify(err)}`);
      this.engine.clearComposition();
      return '';
    }
  }

  clearComposition(): void {
    try {
      this.engine.clearComposition();
    } catch (err) {
      console.error(`clearComposition failed: ${JSON.stringify(err)}`);
    }
  }

  setOption(option: string, value: boolean): boolean {
    try {
      return this.engine.setOption(option, value);
    } catch (err) {
      console.error(`setOption failed: ${option}=${value}, ${JSON.stringify(err)}`);
      return false;
    }
  }

  deploy(): boolean {
    try {
      return this.engine.deploy();
    } catch (err) {
      console.error(`deploy failed: ${JSON.stringify(err)}`);
      return false;
    }
  }

  getStatus(): RimeStatus {
    const status = this.engine.getStatus();
    status.nativeLoaded = this.nativeLoaded;
    return status;
  }

  private async tryLoadNative(): Promise<void> {
    if (this.nativeLoaded) {
      return;
    }
    try {
      const nativeModule: RimeNativeModuleLoader = await (import('librime_bridge.so') as Promise<RimeNativeModuleLoader>);
      if (nativeModule.default) {
        this.engine = nativeModule.default;
      } else if (this.isRimeNativeModule(nativeModule)) {
        this.engine = nativeModule as RimeNativeModule;
      } else {
        throw new Error('librime_bridge.so exports do not match RimeNativeModule');
      }
      this.nativeLoaded = true;
    } catch (err) {
      this.nativeLoaded = false;
      console.info(`librime_bridge.so is unavailable, using ArkTS fallback: ${JSON.stringify(err)}`);
    }
  }

  private isRimeNativeModule(module: RimeNativeModuleLoader): boolean {
    return !!module.init &&
      !!module.processKey &&
      !!module.getComposition &&
      !!module.getCandidates &&
      !!module.commitCandidate &&
      !!module.clearComposition &&
      !!module.setOption &&
      !!module.deploy &&
      !!module.getStatus;
  }
}

const RimeNativeBridge = new RimeNativeBridgeImpl();
export default RimeNativeBridge;
