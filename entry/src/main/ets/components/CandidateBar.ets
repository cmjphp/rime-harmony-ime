@Component
export struct CandidateBar {
  @Prop composition: string = '';
  @Prop candidates: string[] = [];
  @Prop debugStatus: string = '';
  onCandidateSelected: (index: number) => void = () => {};

  build() {
    Column() {
      Row() {
        Scroll() {
          Text(this.composition)
            .fontSize(14)
            .fontColor('#2563EB')
            .maxLines(1)
            .padding({ left: 12, right: 12 })
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        Text(this.debugStatus)
          .fontSize(10)
          .fontColor('#6B7280')
          .maxLines(1)
          .padding({ right: 8 })
      }
      .height(24)
      .width('100%')

      Scroll() {
        Row() {
          ForEach(this.candidates, (candidate: string, index: number) => {
            Button(candidate)
              .height(34)
              .fontSize(16)
              .fontColor('#111827')
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .margin({ right: 6 })
              .onClick(() => {
                this.onCandidateSelected(index);
              });
          }, (candidate: string, index: number) => `${index}-${candidate}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(38)
      .width('100%')
    }
    .height(64)
    .width('100%')
    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
    .backgroundColor('#EEF2F7');
  }
}
