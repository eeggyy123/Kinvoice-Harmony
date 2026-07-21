import { showToast } from '../components/Toast';

@Component
struct ProfileTab {
  @State nickname: string = '';
  @State isLoggedIn: boolean = false;

  @State showPanel: boolean = false;
  @State authMode: string = 'login';
  @State authUsername: string = '';
  @State authPassword: string = '';
  @State authNickname: string = '';
  @State authLoading: boolean = false;

  @State editNickname: string = '';
  @State saving: boolean = false;

  get avatarChar(): string {
    const name = (typeof this.nickname === 'string') ? this.nickname : '';
    return name ? name.charAt(0).toUpperCase() : '?';
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        Column() {
          Row() {
            Column() {
              Text(this.avatarChar)
                .fontSize(44)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff');
            }
            .width(100)
            .height(100)
            .borderRadius(50)
            .backgroundColor('#9cb5c9')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);

            Column() {
              Text(this.nickname || '未登录')
                .fontSize(36)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4a3728');
              Text(this.nickname ? '点击管理账户' : '点击头像登录')
                .fontSize(26)
                .fontColor('#8ab4c9')
                .margin({ top: 8 });
            }
            .flexGrow(1)
            .margin({ left: 24 });
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.showUserPanel());
        }
        .width('100%')
        .padding({ top: 60, bottom: 30, left: 30, right: 30 })
        .backgroundColor('#f5ebe0');

        List({ space: 12 }) {
          this.MenuItem('📋', '用户档案');
          this.MenuItem('🏠', '我的家庭组');
          this.MenuItem('⚙️', '设置');
          this.MenuItem('ℹ️', '关于我们');
          this.MenuItem('❓', '帮助与反馈');
        }
        .width('100%')
        .flexGrow(1)
        .padding({ left: 24, right: 24, bottom: 100 })
        .scrollBar(BarState.Off);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5ebe0');

      if (this.showPanel) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => this.closePanel());
        Column() {
          Row() {
            Text(this.isLoggedIn ? '账户管理' : '登录 / 注册')
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4a3728');
            Column() {
              Text('✕')
                .fontSize(28)
                .fontColor('#9a8b7a');
            }
            .width(56)
            .height(56)
            .borderRadius(28)
            .backgroundColor('#f0e8dd')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.closePanel());
          }
          .width('100%')
          .padding({ left: 30, right: 30, top: 28, bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center);

          if (!this.isLoggedIn) {
            Column() {
              Row() {
                Column() {
                  Text('登录')
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.authMode === 'login' ? '#d4874b' : '#9a8b7a');
                }
                .flexGrow(1)
                .height(64)
                .borderRadius(10)
                .backgroundColor(this.authMode === 'login' ? '#ffffff' : 'transparent')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => this.switchAuthMode('login'));
                Column() {
                  Text('注册')
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.authMode === 'register' ? '#d4874b' : '#9a8b7a');
                }
                .flexGrow(1)
                .height(64)
                .borderRadius(10)
                .backgroundColor(this.authMode === 'register' ? '#ffffff' : 'transparent')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => this.switchAuthMode('register'));
              }
              .width('100%')
              .borderRadius(12)
              .backgroundColor('#f0e8dd')
              .padding(4)
              .margin({ bottom: 20 });

              TextInput({ placeholder: '用户名', text: this.authUsername })
                .width('100%')
                .height(72)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#faf7f3')
                .borderWidth(1)
                .borderColor('#d4c8b8')
                .borderRadius(14)
                .fontSize(28)
                .fontColor('#4a3728')
                .margin({ bottom: 20 })
                .onChange((value: string) => {
                  this.authUsername = value;
                });

              TextInput({ placeholder: '密码', text: this.authPassword })
                .width('100%')
                .height(72)
                .type(InputType.Password)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#faf7f3')
                .borderWidth(1)
                .borderColor('#d4c8b8')
                .borderRadius(14)
                .fontSize(28)
                .fontColor('#4a3728')
                .margin({ bottom: 20 })
                .onChange((value: string) => {
                  this.authPassword = value;
                });

              if (this.authMode === 'register') {
                TextInput({ placeholder: '昵称', text: this.authNickname })
                  .width('100%')
                  .height(72)
                  .padding({ left: 18, right: 18 })
                  .backgroundColor('#faf7f3')
                  .borderWidth(1)
                  .borderColor('#d4c8b8')
                  .borderRadius(14)
                  .fontSize(28)
                  .fontColor('#4a3728')
                  .margin({ bottom: 20 })
                  .onChange((value: string) => {
                    this.authNickname = value;
                  });
              }

              Column() {
                Text(this.authLoading ? '处理中...' : (this.authMode === 'login' ? '登录' : '注册'))
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff');
              }
              .width('100%')
              .height(80)
              .backgroundColor('#d4874b')
              .borderRadius(16)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .margin({ bottom: 16 })
              .onClick(() => this.doAuth());
            }
            .width('100%')
            .padding({ left: 30, right: 30 });
          } else {
            Column() {
              Row() {
                Text('当前昵称')
                  .fontSize(26)
                  .fontColor('#9a8b7a');
                Text(this.nickname)
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4a3728')
                  .margin({ left: 16 });
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 20, bottom: 20 })
              .backgroundColor('#faf7f3')
              .borderRadius(14)
              .margin({ bottom: 24 });

              Text('修改昵称')
                .fontSize(26)
                .fontColor('#9a8b7a')
                .margin({ bottom: 12 });

              TextInput({ placeholder: '输入新昵称', text: this.editNickname })
                .width('100%')
                .height(72)
                .padding({ left: 18, right: 18 })
                .backgroundColor('#faf7f3')
                .borderWidth(1)
                .borderColor('#d4c8b8')
                .borderRadius(14)
                .fontSize(28)
                .fontColor('#4a3728')
                .margin({ bottom: 20 })
                .onChange((value: string) => {
                  this.editNickname = value;
                });

              Column() {
                Text(this.saving ? '保存中...' : '确认修改')
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff');
              }
              .width('100%')
              .height(80)
              .backgroundColor('#d4874b')
              .borderRadius(16)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .margin({ bottom: 16 })
              .onClick(() => this.doUpdateNickname());

              Column()
                .width('100%')
                .height(1)
                .backgroundColor('#f0e8dd')
                .margin({ top: 8, bottom: 20 });

              Column() {
                Text('退出登录')
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#e07070');
              }
              .width('100%')
              .height(80)
              .backgroundColor('#ffffff')
              .borderWidth(2)
              .borderColor('#e07070')
              .borderRadius(16)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => this.doLogout());
            }
            .width('100%')
            .padding({ left: 30, right: 30 });
          }
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius({ topLeft: 28, topRight: 28 })
        .padding({ top: 32, bottom: 120 })
        .transition(TransitionEffect.translate({ x: 0, y: 0 }).animation({ duration: 300, curve: Curve.EaseOut }));
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder MenuItem(icon: string, label: string) {
    ListItem() {
      Row() {
        Text(icon)
          .fontSize(40);
        Text(label)
          .fontSize(30)
          .fontColor('#4a3728')
          .margin({ left: 16 });
        Text('›')
          .fontSize(36)
          .fontColor('#c9b8ad');
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24, bottom: 24 })
      .backgroundColor('#ffffff')
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .onClick(() => this.handleMenuClick(label));
    }
  }

  aboutToAppear(): void {
    this.nickname = '';
    this.isLoggedIn = false;
    this.showPanel = false;
    this.saving = false;
  }

  refresh(): void {
    this.nickname = '';
    this.isLoggedIn = false;
  }

  showUserPanel(): void {
    if (!this.isLoggedIn) {
      this.authMode = 'login';
      this.authUsername = '';
      this.authPassword = '';
      this.authNickname = '';
    } else {
      this.editNickname = this.nickname;
    }
    this.showPanel = true;
  }

  closePanel(): void {
    this.showPanel = false;
    this.authUsername = '';
    this.authPassword = '';
    this.authNickname = '';
    this.editNickname = '';
  }

  switchAuthMode(mode: string): void {
    this.authMode = mode;
  }

  async doAuth(): Promise<void> {
    const username = (this.authUsername || '').trim();
    const password = (this.authPassword || '').trim();
    const nickname = (this.authNickname || '').trim();

    if (!username) {
      showToast('请输入用户名');
      return;
    }
    if (!password) {
      showToast('请输入密码');
      return;
    }
    if (this.authMode === 'register' && !nickname) {
      showToast('请输入昵称');
      return;
    }
    if (this.authLoading) return;

    this.authLoading = true;
    try {
      if (this.authMode === 'login') {
        this.nickname = nickname || username;
        this.isLoggedIn = true;
        this.showPanel = false;
        showToast('登录成功！');
      } else {
        this.nickname = nickname;
        this.isLoggedIn = true;
        this.showPanel = false;
        showToast('注册成功！');
      }
    } catch (e) {
      showToast('操作失败，请重试');
    } finally {
      this.authLoading = false;
    }
  }

  async doUpdateNickname(): Promise<void> {
    const trimmed = (this.editNickname || '').trim();
    if (!trimmed) {
      showToast('昵称不能为空');
      return;
    }
    if (trimmed === this.nickname) {
      showToast('昵称未变化');
      return;
    }
    if (this.saving) return;
    this.saving = true;
    try {
      this.nickname = trimmed;
      this.showPanel = false;
      showToast('昵称已更新');
    } catch (e) {
      showToast('保存失败，请重试');
    } finally {
      this.saving = false;
    }
  }

  doLogout(): void {
    this.nickname = '';
    this.isLoggedIn = false;
    this.showPanel = false;
    showToast('已退出登录');
  }

  handleMenuClick(label: string): void {
    showToast(`${label}功能开发中`);
  }

  goProfileDetail(): void {
    showToast('用户档案功能开发中');
  }

  goFamily(): void {
    showToast('家庭组功能开发中');
  }

  showSettings(): void {
    showToast('设置功能开发中');
  }

  showAbout(): void {
    showToast('关于我们功能开发中');
  }

  showHelp(): void {
    showToast('帮助与反馈功能开发中');
  }
}

export default ProfileTab;