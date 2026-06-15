import RimeNativeBridge from '../native/RimeNativeBridge';

@Entry
@Component
struct SettingsPage {
  @State engineStatus: string = 'arkts-mock';

  aboutToAppear(): void {
    this.engineStatus = RimeNativeBridge.getStatus().engine;
  }

  build() {
    Column() {
      Text('RimeHarmonyIME')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
        .margin({ bottom: 12 });

      Text(`Engine: ${this.engineStatus}`)
        .fontSize(16)
        .fontColor('#374151');

      Text('MVP build: input method extension, ArkTS mock engine, and native stub are prepared.')
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ top: 12 })
        .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F9FAFB');
  }
}
