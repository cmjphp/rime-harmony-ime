import { display } from '@kit.ArkUI';
import { inputMethodEngine, InputMethodExtensionContext } from '@kit.IMEKit';
import fs from '@ohos.file.fs';

const KEYBOARD_HEIGHT_RATE = 0.3;
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
  algebra:
    - erase/^xx$/
    - abbrev/^([a-z]).+$/$1/
    - abbrev/^([zcs]h).+$/$1/
    - derive/^([nl])ve$/$1ue/
    - derive/^([jqxy])u/$1v/
    - derive/un$/uen/
    - derive/ui/uei/
    - derive/iu/iou/

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
我们\two men\t1100
他\tta\t900
他们\tta men\t1000
她\tta\t900
她们\tta men\t950
它\tta\t800
不\tbu\t950
没\tmei\t900
没有\tmei you\t1000
人\tren\t900
会\thui\t880
就\tjiu\t870
也\tye\t860
都\tdou\t850
有\tyou\t920
要\tyao\t870
说\tshuo\t830
这\tzhe\t900
这个\tzhe ge\t950
这里\tzhe li\t850
那\tna\t760
那个\tna ge\t850
那里\tna li\t800
什么\tshen me\t1000
怎么\tzen me\t900
为什么\twei shen me\t850
可以\tke yi\t950
因为\tyin wei\t900
所以\tsuo yi\t880
但是\tdan shi\t870
如果\truguo\t830
已经\tyi jing\t850
还是\thai shi\t840
虽然\tsui ran\t780
知道\tzhi dao\t900
觉得\tjue de\t850
希望\txi wang\t830
应该\tying gai\t840
需要\txu yao\t830
可能\tke neng\t870
现在\txian zai\t900
今天\tjin tian\t880
明天\tming tian\t850
昨天\tzuo tian\t840
时候\tshi hou\t870
工作\tgong zuo\t860
学习\txue xi\t840
生活\tsheng huo\t850
朋友\tpeng you\t860
家\tjia\t880
大家\tda jia\t900
老师\tlao shi\t840
学生\txue sheng\t830
公司\tgong si\t820
手机\tshou ji\t870
电脑\tdian nao\t840
问题\twen ti\t830
谢谢\txie xie\t860
对不起\tdui bu qi\t800
没关系\tmei guan xi\t780
再见\tzai jian\t840
喜欢\txi huan\t870
开心\tkai xin\t820
高兴\tgao xing\t810
快乐\tkuai le\t800
漂亮\tpiao liang\t780
吃\tchi\t850
吃饭\tchi fan\t860
喝\the\t800
睡觉\tshui jiao\t830
走\tzou\t820
来\tlai\t880
去\tqu\t870
看\tkan\t860
听\tting\t820
做\tzuo\t850
想\txiang\t870
用\tyong\t860
给\tgei\t830
让\trang\t810
从\tcong\t800
到\tdao\t870
很\then\t880
太\ttai\t850
最\tzui\t840
比\tbi\t800
更\tgeng\t820
一点\tyi dian\t860
一些\tyi xie\t830
一下\tyi xia\t850
一起\tyi qi\t870
一样\tyi yang\t840
一个\tyi ge\t950
两个\tliang ge\t830
多少\tduo shao\t840
几\tji\t800
大\tda\t880
小\txiao\t860
多\tduo\t850
少\tshao\t820
长\tchang\t800
高\tgao\t810
快\tkuai\t830
慢\tman\t790
新\txin\t840
老\tlao\t820
上\tshang\t870
下\txia\t860
左\tzuo\t800
右\tyou\t800
前\tqian\t830
后\thou\t830
里\tli\t840
外\twai\t820
开\tkai\t840
关\tguan\t820
开始\tkai shi\t870
结束\tjie shu\t800
完成\twan cheng\t790
准备\tzhun bei\t810
告诉\tgao su\t830
帮忙\tbang mang\t800
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
