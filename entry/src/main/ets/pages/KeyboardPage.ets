import { KeyboardView } from '../components/KeyboardView';

@Entry
@Component
struct KeyboardPage {
  build() {
    Column() {
      KeyboardView()
    }
    .width('100%')
    .height('100%')
  }
}
