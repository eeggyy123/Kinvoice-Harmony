@Entry
@Component
struct ProfileDetail {
  build() {
    Column() {
      Text('档案详情')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5c5c5c');
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#e8e4df');
  }
}
