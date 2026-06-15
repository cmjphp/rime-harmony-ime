@Component
export struct KeyButton {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop flex: number = 1;
  onPress: (value: string) => void = () => {};

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Text(this.label)
        .fontSize(16)
        .fontColor('#111827')
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
      .height(46)
      .layoutWeight(this.flex)
      .backgroundColor('#F9FAFB')
      .borderRadius(6)
      .margin({ left: 3, right: 3, top: 4, bottom: 4 })
      .padding(0)
      .onClick(() => {
        this.onPress(this.value.length > 0 ? this.value : this.label);
      });
  }
}
