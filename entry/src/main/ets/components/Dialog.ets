@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController;
  title: string = '';
  message: string = '';
  confirmText: string = '确定';
  cancelText: string = '取消';
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5c5c5c')
          .margin({ bottom: 16 });
      }
      Text(this.message)
        .fontSize(28)
        .fontColor('#5c5c5c')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 32 });
      Row() {
        Button(this.cancelText)
          .width(140)
          .height(60)
          .backgroundColor('#d9d3cb')
          .fontColor('#5c5c5c')
          .fontSize(28)
          .borderRadius(8)
          .onClick(() => {
            this.onCancel();
            this.controller.close();
          });
        Button(this.confirmText)
          .width(140)
          .height(60)
          .backgroundColor('#a3b5c7')
          .fontColor('#ffffff')
          .fontSize(28)
          .borderRadius(8)
          .margin({ left: 32 })
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          });
      }
      .justifyContent(FlexAlign.Center);
    }
    .padding(40)
    .backgroundColor('#faf8f5')
    .borderRadius(12)
    .width(520);
  }
}

export function showConfirmDialog(options: {
  title?: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm?: () => void;
  onCancel?: () => void;
}): void {
  const {
    title = '',
    message,
    confirmText = '确定',
    cancelText = '取消',
    onConfirm = () => {},
    onCancel = () => {}
  } = options;

  const dialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title,
      message,
      confirmText,
      cancelText,
      onConfirm,
      onCancel
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    offset: { dx: 0, dy: 0 }
  });

  dialogController.open();
}
