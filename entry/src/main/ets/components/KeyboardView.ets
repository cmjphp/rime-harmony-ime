import keyboardController from '../inputmethod/KeyboardController';
import RimeNativeBridge from '../native/RimeNativeBridge';
import { CandidateBar } from './CandidateBar';
import { KeyButton } from './KeyButton';

@Component
export struct KeyboardView {
  @State composition: string = '';
  @State candidates: string[] = [];
  @State mode: string = 'letters';
  @State inputMode: string = 'zh';
  @State scriptMode: string = 'simp';
  @State engineStatus: string = 'engine: loading';

  private row1: string[] = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  private row2: string[] = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  private row3: string[] = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];
  private numberRow: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  private symbolRow1: string[] = ['-', '/', ':', ';', '(', ')', '$', '&', '@', '"'];
  private symbolRow2: string[] = ['.', ',', '?', '!', "'", '#'];
  private moreSymbolRow1: string[] = ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='];
  private moreSymbolRow2: string[] = ['_', '\\', '|', '~', '<', '>', '`'];

  aboutToAppear(): void {
    this.initializeRime();
  }

  build() {
    Column() {
      CandidateBar({
        composition: this.composition,
        candidates: this.candidates,
        debugStatus: this.engineStatus,
        onCandidateSelected: (index: number) => this.commitCandidate(index)
      })

      if (this.mode === 'letters') {
        this.letterKeyboard()
      } else if (this.mode === 'symbols') {
        this.symbolKeyboard()
      } else {
        this.moreSymbolKeyboard()
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor('#D1D5DB');
  }

  @Builder
  private letterKeyboard() {
    this.keyRow(this.row1, 8)
    this.keyRow(this.row2, 28)

    Row() {
      Blank()
        .layoutWeight(1.15)
      ForEach(this.row3, (key: string) => {
        KeyButton({ label: key, value: key, onPress: (value: string) => this.handleLetter(value) })
      }, (key: string) => key)
      KeyButton({ label: '⌫', value: 'delete', flex: 1.7, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })

    Row() {
      KeyButton({ label: '123', value: 'symbols', flex: 1.4, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.inputMode === 'zh' ? '中' : 'En', value: 'toggleLanguage', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.scriptMode === 'simp' ? '简' : '繁', value: 'toggleScript', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Space', value: 'space', flex: 2.7, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Return', value: 'enter', flex: 1.8, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: '⌄', value: 'hideKeyboard', flex: 1.1, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })
  }

  @Builder
  private symbolKeyboard() {
    this.printableKeyRow(this.numberRow, 8)
    this.printableKeyRow(this.symbolRow1, 8)

    Row() {
      KeyButton({ label: '#+=', value: 'moreSymbols', flex: 1.45, onPress: (value: string) => this.handleSpecialKey(value) })
      ForEach(this.symbolRow2, (key: string) => {
        KeyButton({ label: key, value: key, onPress: (value: string) => this.handlePrintable(value) })
      }, (key: string) => key)
      KeyButton({ label: '⌫', value: 'delete', flex: 1.45, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })

    Row() {
      KeyButton({ label: 'ABC', value: 'letters', flex: 1.4, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.inputMode === 'zh' ? '中' : 'En', value: 'toggleLanguage', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.scriptMode === 'simp' ? '简' : '繁', value: 'toggleScript', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Space', value: 'space', flex: 2.7, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Return', value: 'enter', flex: 1.8, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: '⌄', value: 'hideKeyboard', flex: 1.1, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })
  }

  @Builder
  private moreSymbolKeyboard() {
    this.printableKeyRow(this.moreSymbolRow1, 8)
    this.printableKeyRow(this.moreSymbolRow2, 28)

    Row() {
      KeyButton({ label: '123', value: 'symbols', flex: 1.45, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: '.', value: '.', flex: 1, onPress: (value: string) => this.handlePrintable(value) })
      KeyButton({ label: ',', value: ',', flex: 1, onPress: (value: string) => this.handlePrintable(value) })
      KeyButton({ label: '?', value: '?', flex: 1, onPress: (value: string) => this.handlePrintable(value) })
      KeyButton({ label: '!', value: '!', flex: 1, onPress: (value: string) => this.handlePrintable(value) })
      KeyButton({ label: "'", value: "'", flex: 1, onPress: (value: string) => this.handlePrintable(value) })
      KeyButton({ label: '⌫', value: 'delete', flex: 1.45, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })

    Row() {
      KeyButton({ label: 'ABC', value: 'letters', flex: 1.4, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.inputMode === 'zh' ? '中' : 'En', value: 'toggleLanguage', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: this.scriptMode === 'simp' ? '简' : '繁', value: 'toggleScript', flex: 1.2, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Space', value: 'space', flex: 2.7, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: 'Return', value: 'enter', flex: 1.8, onPress: (value: string) => this.handleSpecialKey(value) })
      KeyButton({ label: '⌄', value: 'hideKeyboard', flex: 1.1, onPress: (value: string) => this.handleSpecialKey(value) })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })
  }

  @Builder
  private keyRow(keys: string[], horizontalPadding: number) {
    Row() {
      ForEach(keys, (key: string) => {
        KeyButton({ label: key, value: key, onPress: (value: string) => this.handleLetter(value) })
      }, (key: string) => key)
    }
    .width('100%')
    .padding({ left: horizontalPadding, right: horizontalPadding })
  }

  @Builder
  private printableKeyRow(keys: string[], horizontalPadding: number) {
    Row() {
      ForEach(keys, (key: string) => {
        KeyButton({ label: key, value: key, onPress: (value: string) => this.handlePrintable(value) })
      }, (key: string) => key)
    }
    .width('100%')
    .padding({ left: horizontalPadding, right: horizontalPadding })
  }

  private handleLetter(value: string): void {
    if (value.length !== 1) {
      return;
    }
    if (this.inputMode === 'zh') {
      RimeNativeBridge.processKey(value.charCodeAt(0), 0);
      this.refreshEngineState();
      console.info(`RimeHarmonyIME handleLetter zh: ${value}, composition=${this.composition}, candidates=${this.candidates.length}`);
      return;
    } else if (this.composition.length > 0) {
      RimeNativeBridge.clearComposition();
    }
    keyboardController.commitText(value);
    this.refreshEngineState();
  }

  private handleSpecialKey(value: string): void {
    console.info(`RimeHarmonyIME handleSpecialKey: ${value}, inputMode=${this.inputMode}, keyboardMode=${this.mode}`);
    if (value === 'hideKeyboard') {
      keyboardController.hideKeyboard();
      return;
    }
    if (value === 'toggleLanguage') {
      this.toggleLanguage();
      return;
    }
    if (value === 'toggleScript') {
      this.toggleScript();
      return;
    }
    if (value === 'symbols') {
      this.mode = 'symbols';
      return;
    }
    if (value === 'letters') {
      this.mode = 'letters';
      return;
    }
    if (value === 'moreSymbols') {
      this.mode = 'moreSymbols';
      return;
    }
    if (value === 'delete') {
      this.deleteOne();
      return;
    }
    if (value === 'space') {
      this.commitSpace();
      return;
    }
    if (value === 'enter') {
      this.commitEnter();
    }
  }

  private handlePrintable(value: string): void {
    if (this.composition.length > 0) {
      RimeNativeBridge.clearComposition();
      this.refreshEngineState();
    }
    keyboardController.commitText(value);
  }

  private commitCandidate(index: number): void {
    const deleteLength = this.composition.length;
    const text = RimeNativeBridge.commitCandidate(index);
    if (this.inputMode === 'zh') {
      keyboardController.commitText(text);
    } else {
      keyboardController.replaceTextBeforeCursor(deleteLength, text);
    }
    this.refreshEngineState();
  }

  private commitSpace(): void {
    if (this.composition.length > 0) {
      this.commitCandidate(0);
      return;
    }
    keyboardController.commitText(' ');
  }

  private commitEnter(): void {
    if (this.composition.length > 0) {
      RimeNativeBridge.clearComposition();
      this.refreshEngineState();
    }
    keyboardController.sendEnter();
  }

  private deleteOne(): void {
    if (this.composition.length > 0) {
      const next = this.composition.substring(0, this.composition.length - 1);
      RimeNativeBridge.clearComposition();
      for (let index = 0; index < next.length; index++) {
        RimeNativeBridge.processKey(next.charCodeAt(index), 0);
      }
      this.refreshEngineState();
      return;
    }
    keyboardController.deleteBackward(1);
  }

  private async initializeRime(): Promise<void> {
    const initialized = await RimeNativeBridge.init(
      keyboardController.getRimeUserDataDir(),
      keyboardController.getRimeSharedDataDir()
    );
    const deployed = initialized ? RimeNativeBridge.deploy() : false;
    if (initialized) {
      RimeNativeBridge.setOption('simplification', this.scriptMode === 'simp');
    }
    const status = RimeNativeBridge.getStatus();
    this.engineStatus = `${status.engine} ${status.nativeLoaded ? 'native' : 'fallback'} ${status.ready ? 'ready' : 'not-ready'} ${deployed ? 'deployed' : 'not-deployed'}`;
    console.info(`RimeHarmonyIME initializeRime initialized=${initialized}, deployed=${deployed}, engine=${status.engine}, nativeLoaded=${status.nativeLoaded}`);
    this.refreshEngineState();
  }

  private refreshEngineState(): void {
    this.updateEngineStatus();
    if (this.inputMode === 'zh') {
      this.composition = RimeNativeBridge.getComposition();
      this.candidates = RimeNativeBridge.getCandidates();
      return;
    }
    this.composition = '';
    this.candidates = [];
  }

  private updateEngineStatus(): void {
    const status = RimeNativeBridge.getStatus();
    this.engineStatus = `${status.engine} ${status.nativeLoaded ? 'native' : 'fallback'} ${status.ready ? 'ready' : 'not-ready'}`;
  }

  private toggleLanguage(): void {
    const previousMode = this.inputMode;
    if (this.inputMode === 'zh') {
      this.inputMode = 'en';
      RimeNativeBridge.clearComposition();
    } else {
      this.inputMode = 'zh';
    }
    console.info(`RimeHarmonyIME toggleLanguage: ${previousMode} -> ${this.inputMode}`);
    this.refreshEngineState();
  }

  private toggleScript(): void {
    this.scriptMode = this.scriptMode === 'simp' ? 'trad' : 'simp';
    const changed = RimeNativeBridge.setOption('simplification', this.scriptMode === 'simp');
    console.info(`RimeHarmonyIME toggleScript: ${this.scriptMode}, changed=${changed}`);
    this.refreshEngineState();
  }
}
