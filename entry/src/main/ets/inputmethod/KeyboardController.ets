import { display } from '@kit.ArkUI';
import { inputMethodEngine, InputMethodExtensionContext } from '@kit.IMEKit';
import fs from '@ohos.file.fs';

const KEYBOARD_HEIGHT_RATE = 0.42;
const FALLBACK_ENTER_KEY_TYPE: number = inputMethodEngine.ENTER_KEY_TYPE_NEWLINE;
const inputMethodAbility: inputMethodEngine.InputMethodAbility = inputMethodEngine.getInputMethodAbility();
const LUNA_PINYIN_DICT_RAWFILE: string = 'rime/luna_pinyin.dict.yaml';
const ESSAY_RAWFILE: string = 'rime/essay.txt';
const OPENCC_T2S_CONFIG_RAWFILE: string = 'rime/opencc/t2s_text.json';
const OPENCC_TS_CHARACTERS_RAWFILE: string = 'rime/opencc/TSCharacters.txt';
const OPENCC_TS_PHRASES_RAWFILE: string = 'rime/opencc/TSPhrases.txt';
const RIME_DEFAULT_YAML: string = `schema_list:
  - schema: rime_harmony

menu:
  page_size: 9
`;
const RIME_HARMONY_SCHEMA_YAML: string = `schema:
  schema_id: rime_harmony
  name: Rime Harmony MVP
  version: "0.1"

switches:
  - name: ascii_mode
    reset: 0
    states: [ 中文, ABC ]
  - name: simplification
    reset: 1
    states: [ 繁, 简 ]

engine:
  processors:
    - ascii_composer
    - recognizer
    - key_binder
    - speller
    - punctuator
    - selector
    - navigator
    - express_editor
  segmentors:
    - ascii_segmentor
    - matcher
    - abc_segmentor
    - punct_segmentor
    - fallback_segmentor
  translators:
    - punct_translator
    - script_translator
  filters:
    - simplifier
    - uniquifier

speller:
  alphabet: zyxwvutsrqponmlkjihgfedcba
  delimiter: " '"

translator:
  dictionary: luna_pinyin
  enable_completion: true
  enable_sentence: true
  enable_user_dict: false

simplifier:
  option_name: simplification
  opencc_config: t2s_text.json
  tips: none
  inherit_comment: true

punctuator:
  full_shape:
    ' ' : { commit: '　' }
    ',' : { commit: ， }
    '.' : { commit: 。 }
    '?' : { commit: ？ }
    '!' : { commit: ！ }
  half_shape:
    ',' : { commit: ， }
    '.' : { commit: 。 }
    '?' : { commit: ？ }
    '!' : { commit: ！ }

key_binder:
  bindings: []

recognizer:
  patterns: {}
`;
const RIME_HARMONY_DICT_YAML: string = `---
name: rime_harmony
version: "0.1"
sort: by_weight
use_preset_vocabulary: false
...
你\tni\t1000
呢\tne\t900
尼\tni\t800
拟\tni\t700
泥\tni\t600
年\tnian\t800
南\tnan\t780
那\tna\t760
能\tneng\t740
你好\tni hao\t1200
你们\tni men\t1100
你呢\tni ne\t1000
您好\tnin hao\t980
中\tzhong\t1000
国\tguo\t950
中国\tzhong guo\t1300
中国人\tzhong guo ren\t1100
中过\tzhong guo\t700
中果\tzhong guo\t650
我\two\t1000
是\tshi\t950
的\tde\t950
了\tle\t900
在\tzai\t880
和\the\t860
好\thao\t900
好啊\thao a\t850
吗\tma\t850
测试\tce shi\t800
输入\tshu ru\t800
输入法\tshu ru fa\t900
鸿蒙\thong meng\t900
`;
const RIME_USER_YAML: string = `var:
  option:
    simplification: true
`;

export class KeyboardController {
  private context?: InputMethodExtensionContext;
  private panel?: inputMethodEngine.Panel;
  private textInputClient?: inputMethodEngine.InputClient;
  private keyboardController?: inputMethodEngine.KeyboardController;
  private userDataDir: string = '';
  private sharedDataDir: string = '';

  onCreate(context: InputMethodExtensionContext): void {
    this.context = context;
    this.prepareRimeDataDirs(context);
    this.createPanel();
    this.registerInputListeners();
  }

  onDestroy(): void {
    this.unregisterInputListeners();
    if (this.panel) {
      this.panel.hide();
      inputMethodAbility.destroyPanel(this.panel);
      this.panel = undefined;
    }
  }

  commitText(text: string): void {
    if (text.length === 0) {
      return;
    }
    if (!this.textInputClient) {
      return;
    }
    try {
      this.textInputClient.insertText(text)
        .catch((err: Error) => {
          console.error(`insertText promise failed: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      console.error(`commitText failed: ${JSON.stringify(err)}`);
    }
  }

  deleteBackward(length: number = 1): void {
    if (!this.textInputClient) {
      console.error('deleteBackward: textInputClient is undefined');
      return;
    }
    try {
      this.textInputClient.deleteForward(length)
        .catch((err: Error) => {
          console.error(`deleteForward promise failed: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      console.error(`deleteBackward failed: ${JSON.stringify(err)}`);
    }
  }

  replaceTextBeforeCursor(deleteLength: number, text: string): void {
    if (!this.textInputClient) {
      return;
    }
    try {
      this.textInputClient.deleteForward(deleteLength)
        .then(() => {
          if (text.length > 0) {
            this.commitText(text);
          }
        })
        .catch((err: Error) => {
          console.error(`replaceTextBeforeCursor failed: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      console.error(`replaceTextBeforeCursor failed: ${JSON.stringify(err)}`);
    }
  }

  sendEnter(): void {
    if (!this.textInputClient) {
      return;
    }
    try {
      let enterKeyType = FALLBACK_ENTER_KEY_TYPE;
      try {
        enterKeyType = this.textInputClient.getEditorAttributeSync().enterKeyType;
      } catch (err) {
        console.info(`getEditorAttributeSync failed, use newline enter: ${JSON.stringify(err)}`);
      }
      this.textInputClient.sendKeyFunction(enterKeyType)
        .catch((err: Error) => {
          console.error(`sendKeyFunction promise failed: ${JSON.stringify(err)}`);
          this.commitText('\n');
        });
    } catch (err) {
      console.error(`sendEnter failed: ${JSON.stringify(err)}`);
      this.commitText('\n');
    }
  }

  hideKeyboard(): void {
    try {
      this.keyboardController?.hide();
    } catch (err) {
      console.error(`hideKeyboard failed: ${JSON.stringify(err)}`);
    }
  }

  getRimeUserDataDir(): string {
    return this.userDataDir;
  }

  getRimeSharedDataDir(): string {
    return this.sharedDataDir;
  }

  private prepareRimeDataDirs(context: InputMethodExtensionContext): void {
    const baseDir = `${context.filesDir}/rime`;
    this.userDataDir = `${baseDir}/user`;
    this.sharedDataDir = `${baseDir}/shared`;
    this.ensureDir(baseDir);
    this.ensureDir(this.userDataDir);
    this.ensureDir(this.sharedDataDir);
    this.prepareRimeRuntimeFiles(context);
  }

  private ensureDir(path: string): void {
    try {
      if (!fs.accessSync(path)) {
        fs.mkdirSync(path, true);
      }
    } catch (err) {
      try {
        fs.mkdirSync(path, true);
      } catch (mkdirErr) {
        console.error(`ensureDir failed: ${path}, ${JSON.stringify(mkdirErr)}`);
      }
    }
  }

  private prepareRimeRuntimeFiles(context: InputMethodExtensionContext): void {
    this.ensureDir(`${this.sharedDataDir}/opencc`);
    this.ensureDir(`${this.userDataDir}/opencc`);
    this.writeTextFile(`${this.sharedDataDir}/default.yaml`, RIME_DEFAULT_YAML);
    this.writeTextFile(`${this.sharedDataDir}/rime_harmony.schema.yaml`, RIME_HARMONY_SCHEMA_YAML);
    this.writeTextFile(`${this.sharedDataDir}/rime_harmony.dict.yaml`, RIME_HARMONY_DICT_YAML);
    this.writeRawFile(context, LUNA_PINYIN_DICT_RAWFILE, `${this.sharedDataDir}/luna_pinyin.dict.yaml`);
    this.writeRawFile(context, ESSAY_RAWFILE, `${this.sharedDataDir}/essay.txt`);
    this.writeRawFile(context, OPENCC_T2S_CONFIG_RAWFILE, `${this.sharedDataDir}/opencc/t2s_text.json`);
    this.writeRawFile(context, OPENCC_TS_CHARACTERS_RAWFILE, `${this.sharedDataDir}/opencc/TSCharacters.txt`);
    this.writeRawFile(context, OPENCC_TS_PHRASES_RAWFILE, `${this.sharedDataDir}/opencc/TSPhrases.txt`);
    this.writeTextFile(`${this.userDataDir}/default.yaml`, RIME_DEFAULT_YAML);
    this.writeTextFile(`${this.userDataDir}/rime_harmony.schema.yaml`, RIME_HARMONY_SCHEMA_YAML);
    this.writeTextFile(`${this.userDataDir}/rime_harmony.dict.yaml`, RIME_HARMONY_DICT_YAML);
    this.writeRawFile(context, LUNA_PINYIN_DICT_RAWFILE, `${this.userDataDir}/luna_pinyin.dict.yaml`);
    this.writeRawFile(context, ESSAY_RAWFILE, `${this.userDataDir}/essay.txt`);
    this.writeRawFile(context, OPENCC_T2S_CONFIG_RAWFILE, `${this.userDataDir}/opencc/t2s_text.json`);
    this.writeRawFile(context, OPENCC_TS_CHARACTERS_RAWFILE, `${this.userDataDir}/opencc/TSCharacters.txt`);
    this.writeRawFile(context, OPENCC_TS_PHRASES_RAWFILE, `${this.userDataDir}/opencc/TSPhrases.txt`);
    this.writeTextFile(`${this.userDataDir}/user.yaml`, RIME_USER_YAML);
  }

  private writeTextFile(path: string, content: string): void {
    let file: fs.File | undefined = undefined;
    try {
      file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, content);
    } catch (err) {
      console.error(`writeTextFile failed: ${path}, ${JSON.stringify(err)}`);
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (closeErr) {
          console.error(`close file failed: ${path}, ${JSON.stringify(closeErr)}`);
        }
      }
    }
  }

  private writeRawFile(context: InputMethodExtensionContext, rawFilePath: string, targetPath: string): void {
    let file: fs.File | undefined = undefined;
    try {
      const content: Uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);
      file = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, content.buffer);
    } catch (err) {
      console.error(`writeRawFile failed: ${rawFilePath} -> ${targetPath}, ${JSON.stringify(err)}`);
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (closeErr) {
          console.error(`close raw file failed: ${targetPath}, ${JSON.stringify(closeErr)}`);
        }
      }
    }
  }

  private createPanel(): void {
    if (!this.context) {
      return;
    }
    try {
      const screen = display.getDefaultDisplaySync();
      const panelHeight = Math.floor(screen.height * KEYBOARD_HEIGHT_RATE);
      const panelInfo: inputMethodEngine.PanelInfo = {
        type: inputMethodEngine.PanelType.SOFT_KEYBOARD,
        flag: inputMethodEngine.PanelFlag.FLG_FIXED
      };

      inputMethodAbility.createPanel(this.context, panelInfo)
        .then(async (panel: inputMethodEngine.Panel) => {
          this.panel = panel;
          await panel.resize(screen.width, panelHeight);
          await panel.moveTo(0, screen.height - panelHeight);
          await panel.setUiContent('pages/KeyboardPage');
        })
        .catch((err: Error) => {
          console.error(`create input method panel failed: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      console.error(`prepare input method panel failed: ${JSON.stringify(err)}`);
    }
  }

  private registerInputListeners(): void {
    inputMethodAbility.on('inputStart', (
      keyboardController: inputMethodEngine.KeyboardController,
      textInputClient: inputMethodEngine.InputClient
    ) => {
      this.keyboardController = keyboardController;
      this.textInputClient = textInputClient;
    });

    inputMethodAbility.on('inputStop', () => {
      this.textInputClient = undefined;
      this.keyboardController = undefined;
    });
  }

  private unregisterInputListeners(): void {
    inputMethodAbility.off('inputStart');
  }
}

const keyboardController = new KeyboardController();
export default keyboardController;
