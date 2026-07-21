@Entry
@Component
struct KinVoiceCard {
  @State title: string = '家语 AI';
  @State subtitle: string = '你的家庭情绪树洞';
  @State greeting: string = '今天过得开心吗？';

  build() {
    Column() {
      Column() {
        Text(this.title)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5c5c5c');
        Text(this.subtitle)
          .fontSize(20)
          .fontColor('#9a9490')
          .margin({ top: 4 });
      }
      .width('100%')
      .padding({ top: 16, left: 16, right: 16 });

      Column() {
        Text(this.greeting)
          .fontSize(24)
          .fontColor('#5c5c5c')
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .flexGrow(1)
      .padding({ left: 16, right: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center);

      Column() {
        Text('点击打开')
          .fontSize(20)
          .fontColor('#a3b5c7');
      }
      .width('100%')
      .padding({ bottom: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#faf8f5')
    .borderRadius(12);
  }
}
