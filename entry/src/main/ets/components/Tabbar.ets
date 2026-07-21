@Component
struct Tabbar {
  activeTab: string = 'companion';
  onTabChange: (key: string) => void = () => {};
  @State pressedTab: string = '';

  build() {
    Row() {
      this.TabItem('companion', '🏠', '陪伴');
      this.TabItem('breakIce', '💬', '聊天');
      this.TabItem('memory', '📚', '传承');
      this.TabItem('profile', '👤', '我的');
    }
    .width('100%')
    .height(100)
    .backgroundColor('#ffffff')
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .borderWidth({ top: 1 })
    .borderColor('#f0e8df')
    .position({ bottom: 0, left: 0, right: 0 });
  }

  @Builder TabItem(key: string, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(36)
        .opacity(this.activeTab === key ? 1 : 0.5)
        .scale({ x: this.activeTab === key ? 1.08 : 1, y: this.activeTab === key ? 1.08 : 1 });
      Text(label)
        .fontSize(22)
        .fontColor(this.activeTab === key ? '#d4874b' : '#9a8b7a')
        .fontWeight(this.activeTab === key ? FontWeight.Bold : FontWeight.Normal)
        .margin({ top: 4 });
    }
    .flexGrow(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 8, bottom: 8 })
    .borderRadius(12)
    .scale({ x: this.pressedTab === key ? 0.9 : 1, y: this.pressedTab === key ? 0.9 : 1 })
    .backgroundColor(this.pressedTab === key ? 'rgba(212, 135, 75, 0.08)' : 'transparent')
    .onClick(() => {
      if (key !== this.activeTab) {
        this.onTabChange(key);
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedTab = key;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedTab = '';
      }
    });
  }
}

export default Tabbar;