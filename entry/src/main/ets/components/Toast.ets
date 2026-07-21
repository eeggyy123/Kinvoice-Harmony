@CustomDialog
export struct ToastDialog {
  controller: CustomDialogController;
  message: string = '';

  build() {
    Column() {
      Text(this.message)
        .fontSize(26)
        .fontColor('#ffffff')
        .padding({ left: 32, right: 32, top: 20, bottom: 20 })
        .backgroundColor('rgba(0, 0, 0, 0.7)')
        .borderRadius(8)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

export function showToast(message: string, duration: number = 2000): void {
  const dialogController = new CustomDialogController({
    builder: ToastDialog({
      message: message
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    offset: { dx: 0, dy: 0 }
  });

  dialogController.open();

  setTimeout(() => {
    dialogController.close();
  }, duration);
}
