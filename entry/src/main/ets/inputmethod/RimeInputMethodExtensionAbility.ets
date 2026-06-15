import { Want } from '@kit.AbilityKit';
import { InputMethodExtensionAbility } from '@kit.IMEKit';
import keyboardController from './KeyboardController';

export default class RimeInputMethodExtensionAbility extends InputMethodExtensionAbility {
  onCreate(want: Want): void {
    keyboardController.onCreate(this.context);
  }

  onDestroy(): void {
    keyboardController.onDestroy();
  }
}
