@CustomDialog
export struct LoadingDialog {
  controller: CustomDialogController;
  message: string = '加载中...';

  build() {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(60)
            .height(60)
            .fill(Color.Transparent)
            .borderWidth(4)
            .borderColor('#a3b5c7')
            .borderStyle(BorderStyle.Dashed)
            .rotate({ angle: 360 })
            .animation({
              duration: 1000,
              iterations: -1,
              curve: Curve.Linear
            });
          Circle()
            .width(40)
            .height(40)
            .fill(Color.Transparent)
            .borderWidth(3)
            .borderColor('#b5c4b1')
            .borderStyle(BorderStyle.Dashed)
            .rotate({ angle: -360 })
            .animation({
              duration: 800,
              iterations: -1,
              curve: Curve.Linear
            });
        }
        Text(this.message)
          .fontSize(26)
          .fontColor('#5c5c5c')
          .margin({ top: 20 })
      }
      .padding(40)
      .backgroundColor('#faf8f5')
      .borderRadius(12)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

export class LoadingController {
  private dialogController: CustomDialogController | null = null;

  show(message: string = '加载中...'): void {
    if (this.dialogController) {
      this.dialogController.close();
    }
    this.dialogController = new CustomDialogController({
      builder: LoadingDialog({
        message: message
      }),
      alignment: DialogAlignment.Center,
      autoCancel: false,
      offset: { dx: 0, dy: 0 }
    });
    this.dialogController.open();
  }

  hide(): void {
    if (this.dialogController) {
      this.dialogController.close();
      this.dialogController = null;
    }
  }
}

export const loadingController = new LoadingController();
