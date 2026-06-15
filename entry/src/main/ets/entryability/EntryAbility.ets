import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('pages/SettingsPage');
    } catch (err) {
      console.error(`load settings page failed: ${JSON.stringify(err)}`);
    }
  }
}
