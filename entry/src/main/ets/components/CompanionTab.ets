import { Constants, formatDate, generateLocalId, makeTitle, getStorage, setStorage, removeStorage } from '../utils';
import { ChatAPI, FamilyAPI } from '../services/api';
import { showToast } from '../components/Toast';

interface MessageItem {
  role: string;
  content: string;
  id?: string;
}

interface ConversationItem {
  id: number;
  title: string;
  created_at: string;
}

interface ContextMenuState {
  visible: boolean;
  top: number;
  left: number;
  msg: MessageItem | null;
}

@Component
struct CompanionTab {
  @State messageText: string = '';
  @State messages: MessageItem[] = [];
  @State isThinking: boolean = false;
  @State conversationId: number | null = null;
  @State showSidebar: boolean = false;
  @State conversationList: ConversationItem[] = [];
  @State mounted: boolean = true;
  @State timers: number[] = [];
  @State familyId: string | null = null;
  @State familyIdPromise: Promise<void> | null = null;
  @State contextMenu: ContextMenuState = { visible: false, top: 0, left: 0, msg: null };
  @State lastClickTime: number = 0;
  @State lastClickIndex: number = -1;

  build() {
    Stack() {
      if (this.showSidebar) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .onClick(() => this.closeSidebar());
      }

      Column({ space: 0 }) {
        Column() {
          Row() {
            Row() {
              Text('')
                .width(48)
                .height(40)
                .padding({ top: 4, bottom: 4, left: 6, right: 6 });
            }
            .width(48)
            .height(40)
            .position({ left: 20, top: 34 })
            .onClick(() => this.toggleSidebar());

            Column() {
              Text('Cloudie')
                .fontSize(34)
                .fontWeight(FontWeight.Bold)
                .fontColor('#5c5c5c');
              Text('你的家庭情绪树洞')
                .fontSize(22)
                .fontColor('#9a9490')
                .margin({ top: 4 });
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          }
          .width('100%')
          .padding({ top: 30, bottom: 16, left: 30, right: 30 });
        }
        .backgroundColor('#e8e4df');

        List({ space: 16 }) {
          ForEach(this.messages, (msg: MessageItem, index: number) => {
            ListItem() {
              if (msg.role === 'assistant') {
                Row() {
                  Column() {
                    Text('☁')
                      .fontSize(32);
                  }
                  .width(72)
                  .height(72)
                  .borderRadius(8)
                  .backgroundColor('#a3b5c7')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);
                  Column() {
                    Text(msg.content)
                      .fontSize(28)
                      .fontColor('#5c5c5c')
                      .lineHeight(36)
                      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
                      .backgroundColor('#d4c5c0')
                      .borderRadius(8);
                  }
                  .margin({ left: 10 });
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .padding({ right: 60 });
              } else if (msg.role === 'user') {
                Row() {
                  Column() {
                    Text(msg.content)
                      .fontSize(28)
                      .fontColor('#5c5c5c')
                      .lineHeight(36)
                      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
                      .backgroundColor('#b5c4b1')
                      .borderRadius(8);
                  }
                  .margin({ right: 10 });
                  Column() {
                    Text('我')
                      .fontSize(24)
                      .fontColor('#faf8f5')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width(72)
                  .height(72)
                  .backgroundColor('#c4b7a6')
                  .borderRadius(8)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
                .padding({ left: 60 });
              } else {
                Row() {
                  Text(msg.content)
                    .fontSize(22)
                    .fontColor('#9a9490')
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .backgroundColor('rgba(0, 0, 0, 0.04)')
                    .borderRadius(6);
                }
                .width('100%')
                .justifyContent(FlexAlign.Center);
              }
            }
            .onClick(() => this.handleMessageClick(index));
          });

          if (this.isThinking) {
            ListItem() {
              Row() {
                Column() {
                  Text('☁')
                    .fontSize(32);
                }
                .width(72)
                .height(72)
                .borderRadius(8)
                .backgroundColor('#a3b5c7')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center);
                Column() {
                  Text('...')
                    .fontSize(32)
                    .fontColor('#9a9490')
                    .letterSpacing(4)
                    .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                    .backgroundColor('#d4c5c0')
                    .borderRadius(8);
                }
                .margin({ left: 10 });
              }
              .width('100%')
              .justifyContent(FlexAlign.Start);
            }
          }

          ListItem() {
            Column()
              .height(20);
          }
        }
        .width('100%')
        .flexGrow(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 180 })
        .scrollBar(BarState.Off);

        Row() {
          TextInput({ placeholder: '告诉小云你的心事吧...' })
            .width('100%')
            .height(68)
            .padding({ left: 20, right: 20 })
            .backgroundColor('#e8e4df')
            .borderRadius(6)
            .fontSize(28)
            .fontColor('#5c5c5c')
            .placeholderColor('#9a9490')
            .onChange((value: string) => {
              this.messageText = value;
            });
          Column() {
            Text('→')
              .fontSize(32)
              .fontColor('#faf8f5')
              .fontWeight(FontWeight.Bold);
          }
          .width(68)
          .height(68)
          .backgroundColor('#a3b5c7')
          .borderRadius(6)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ left: 10 })
          .onClick(() => this.sendMessage());
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })
        .backgroundColor('#faf8f5')
        .borderWidth({ top: 1 })
        .borderColor('#d9d3cb')
        .position({ bottom: 100, left: 0, right: 0 });
      }
      .width('100%')
      .height('100%');

      if (this.showSidebar) {
        Column() {
          Row() {
            Text('对话记录')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#5c5c5c');
            Column() {
              Text('+')
                .fontSize(36)
                .fontColor('#faf8f5')
                .fontWeight(FontWeight.Lighter);
            }
            .width(56)
            .height(56)
            .backgroundColor('#b5c4b1')
            .borderRadius(28)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.newConversation());
          }
          .width('100%')
          .padding({ left: 30, right: 30, top: 40, bottom: 20 })
          .borderWidth({ bottom: 1 })
          .borderColor('#d9d3cb');

          List({ space: 0 }) {
            ForEach(this.conversationList, (conv: ConversationItem) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(conv.title)
                      .fontSize(26)
                      .fontColor('#5c5c5c')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                    Text(conv.created_at)
                      .fontSize(20)
                      .fontColor('#9a9490')
                      .margin({ top: 4 });
                  }
                  .flexGrow(1);
                  Column() {
                    Text('×')
                      .fontSize(28)
                      .fontColor('#5c5c5c')
                      .fontWeight(FontWeight.Lighter);
                  }
                  .width(52)
                  .height(52)
                  .backgroundColor('#d4c5c0')
                  .borderRadius(26)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .margin({ left: 12 })
                  .onClick((event: ClickEvent) => {
                    event.preventDefault();
                    this.deleteConversation(conv.id);
                  });
                }
                .width('100%')
                .padding({ left: 30, right: 30, top: 20, bottom: 20 })
                .backgroundColor(this.conversationId === conv.id ? '#e8e4df' : '#faf8f5')
                .borderWidth({ bottom: 1 })
                .borderColor('#d9d3cb')
                .onClick(() => this.switchConversation(conv.id));
              }
            });

            if (this.conversationList.length === 0) {
              ListItem() {
                Text('暂无对话记录')
                  .fontSize(24)
                  .fontColor('#9a9490')
                  .padding({ top: 60, bottom: 60 });
              }
            }
          }
          .width('100%')
          .flexGrow(1);
        }
        .width(560)
        .height('100%')
        .backgroundColor('#faf8f5')
        .position({ left: 0, top: 0 });
      }

      if (this.contextMenu.visible) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.2)')
          .onClick(() => this.closeContextMenu());
        Column() {
          Row() {
            Text('🔊')
              .fontSize(28)
              .margin({ right: 12 });
            Text('播放消息')
              .fontSize(26)
              .fontColor('#4a3728');
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.handlePlayClick());
          Row() {
            Text('🗑️')
              .fontSize(28)
              .margin({ right: 12 });
            Text('删除消息')
              .fontSize(26)
              .fontColor('#4a3728');
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.handleDeleteClick());
        }
        .width(280)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .padding({ top: 8, bottom: 8 })
        .position({ left: this.contextMenu.left, top: this.contextMenu.top });
      }
    }
    .width('100%')
    .height('100%');
  }

  aboutToAppear(): void {
    this.mounted = true;
    this.messageText = '';
    this.isThinking = false;
    this.conversationId = null;
    this.showSidebar = false;
    this.conversationList = [];
    this.timers = [];
    this.familyId = null;
    this.familyIdPromise = null;
    const initMsg: MessageItem = { role: 'assistant', content: '今天过得开心吗？戳戳我，或者直接跟我说说话吧！' };
    this.messages = [initMsg];
    this.restoreConvList();
    this.restoreCurrentConv();
    this.syncFromBackend();
    this.fetchFamilyId();
  }

  aboutToDisappear(): void {
    this.mounted = false;
    this.clearTimers();
    this.cacheCurrentConv();
  }

  clearTimers(): void {
    if (Array.isArray(this.timers)) {
      this.timers.forEach((timer) => {
        if (timer) clearTimeout(timer);
      });
    }
    this.timers = [];
  }

  async restoreConvList(): Promise<void> {
    try {
      const data = await getStorage(Constants.STORAGE_KEY_CONV_LIST);
      if (data && Array.isArray(data)) {
        this.conversationList = data;
      }
    } catch (e) {
      console.error('[Companion] restoreConvList failed:', e);
    }
  }

  async saveConvList(): Promise<void> {
    try {
      await setStorage(Constants.STORAGE_KEY_CONV_LIST, this.conversationList);
    } catch (e) {
      console.error('[Companion] saveConvList failed:', e);
    }
  }

  upsertConvInList(convId: number, title: string, createdAt: string): void {
    const existing = this.conversationList.find((c: ConversationItem) => c.id === convId);
    if (existing) {
      existing.title = title || existing.title;
    } else {
      const newItem: ConversationItem = { id: convId, title: title || '新对话', created_at: createdAt };
      this.conversationList.unshift(newItem);
    }
    this.saveConvList();
  }

  msgKey(convId: number): string {
    return Constants.STORAGE_KEY_CONV_MSG_PREFIX + convId;
  }

  async loadConvMessages(convId: number, callback: (msgs: MessageItem[] | null) => void): Promise<void> {
    try {
      const data = await getStorage(this.msgKey(convId));
      if (data && Array.isArray(data)) {
        callback(data);
        return;
      }
    } catch (e) {}
    callback(null);
  }

  async cacheCurrentConv(): Promise<void> {
    if (!this.conversationId || !this.messages || this.messages.length === 0) return;
    try {
      await setStorage(this.msgKey(this.conversationId), this.messages);
    } catch (e) {
      console.error('[Companion] cacheCurrentConv failed:', e);
    }
  }

  async deleteConvMessages(convId: number): Promise<void> {
    try {
      await removeStorage(this.msgKey(convId));
    } catch (e) {}
  }

  async restoreCurrentConv(): Promise<void> {
    try {
      const data = await getStorage(Constants.STORAGE_KEY_CONV_ID);
      let savedId: number | null = null;
      if (typeof data === 'number' && data > 0) {
        savedId = data;
      }
      if (savedId) {
        this.conversationId = savedId;
        this.loadConvMessages(savedId, (msgs) => {
          if (!this.mounted) return;
          if (msgs && msgs.length > 0) {
            this.messages = msgs;
          } else {
            this.messages = [this.welcomeMsg()];
          }
        });
      } else {
        this.createNewConversation(false);
      }
    } catch (e) {
      console.error('[Companion] restoreCurrentConv failed:', e);
      this.createNewConversation(false);
    }
  }

  async saveCurrentConvId(id: number): Promise<void> {
    try {
      await setStorage(Constants.STORAGE_KEY_CONV_ID, id);
    } catch (e) {
      console.error('保存会话 ID 失败:', e);
    }
  }

  welcomeMsg(): MessageItem {
    return { role: 'assistant', content: '今天过得开心吗？戳戳我，或者直接跟我说说话吧！' };
  }

  async syncFromBackend(): Promise<void> {
    try {
      const response = await ChatAPI.listConversations();
      if (response.data && Array.isArray(response.data.conversations)) {
        const localMap: Record<number, ConversationItem> = {};
        this.conversationList.forEach((c: ConversationItem) => { localMap[c.id] = c; });
        let changed = false;
        response.data.conversations.forEach((c: ConversationItem) => {
          if (localMap[c.id]) {
            if (c.title && localMap[c.id].title !== c.title) {
              localMap[c.id].title = c.title;
              changed = true;
            }
          } else {
            const newItem: ConversationItem = {
              id: c.id,
              title: c.title || '新对话',
              created_at: c.created_at ? formatDate(c.created_at) : formatDate(Date.now())
            };
            this.conversationList.unshift(newItem);
            changed = true;
          }
        });
        if (changed) {
          await this.saveConvList();
        }
      }
    } catch (e) {}
  }

  async fetchFamilyId(): Promise<void> {
    if (this.familyIdPromise) {
      return this.familyIdPromise;
    }
    this.familyIdPromise = FamilyAPI.getMyGroup().then((response) => {
      if (!this.mounted) return;
      if (response.data && response.data.family_id) {
        this.familyId = response.data.family_id;
      }
    }).catch(() => {});
    return this.familyIdPromise;
  }

  toggleSidebar(): void {
    this.showSidebar = !this.showSidebar;
  }

  closeSidebar(): void {
    this.showSidebar = false;
  }

  async newConversation(): Promise<void> {
    await this.cacheCurrentConv();
    this.createNewConversation(true);
  }

  createNewConversation(closeSidebar: boolean): void {
    const newId = generateLocalId();
    this.conversationId = newId;
    this.saveCurrentConvId(newId);
    const initMsg: MessageItem = { role: 'assistant', content: '今天过得开心吗？戳戳我，或者直接跟我说说话吧！' };
    this.messages = [initMsg];
    this.upsertConvInList(newId, '新对话', formatDate(Date.now()));
    this.cacheCurrentConv();
    if (closeSidebar) {
      this.showSidebar = false;
    }
  }

  async switchConversation(targetId: number): Promise<void> {
    if (targetId === this.conversationId) {
      this.showSidebar = false;
      return;
    }
    await this.cacheCurrentConv();
    this.conversationId = targetId;
    await this.saveCurrentConvId(targetId);
    this.showSidebar = false;
    this.loadConvMessages(targetId, (msgs) => {
      if (!this.mounted) return;
      if (msgs && msgs.length > 0) {
        this.messages = msgs;
      } else {
        this.messages = [this.welcomeMsg()];
      }
    });
  }

  async deleteConversation(convId: number): Promise<void> {
    this.conversationList = this.conversationList.filter((c: ConversationItem) => c.id !== convId);
    await this.saveConvList();
    await this.deleteConvMessages(convId);
    if (typeof convId === 'number' && convId < 1e10) {
      try {
        await ChatAPI.deleteConversation(convId);
      } catch (e) {}
    }
    if (this.conversationId === convId) {
      this.createNewConversation(false);
    }
    showToast('已删除');
  }

  async sendMessage(): Promise<void> {
    if (this.isThinking) {
      showToast('请等小云回复完再发送');
      return;
    }
    const content = this.messageText.trim();
    if (!content) {
      showToast('请输入内容');
      return;
    }

    const isFirstMessage = !this.messages.some((m: MessageItem) => m.role === 'user');
    const userMsg: MessageItem = { role: 'user', content };
    this.messages.push(userMsg);
    this.messageText = '';

    if (isFirstMessage) {
      this.upsertConvInList(this.conversationId!, makeTitle(this.messages), formatDate(Date.now()));
    }
    await this.cacheCurrentConv();

    this.isThinking = true;

    const familyReady = this.familyIdPromise
      ? this.familyIdPromise.catch(() => {})
      : Promise.resolve();

    familyReady.then(async () => {
      try {
        const response = await ChatAPI.sendMessage(content, this.conversationId || undefined, this.familyId || undefined);
        if (!this.mounted) return;
        this.isThinking = false;
        if (response.data && response.data.reply) {
          const replyMsg: MessageItem = { role: 'assistant', content: response.data.reply };
          this.messages.push(replyMsg);
          await this.cacheCurrentConv();
          if (response.data.conversation_id && response.data.conversation_id !== this.conversationId) {
            await this.migrateConvId(this.conversationId!, response.data.conversation_id);
          }
        } else {
          showToast('AI 回复为空，请重试');
        }
      } catch (e) {
        if (!this.mounted) return;
        this.isThinking = false;
        console.error('[Companion] API Error:', e);
        showToast('AI 回复失败，请重试');
      }
    });
  }

  async migrateConvId(oldId: number, newId: number): Promise<void> {
    if (!oldId || !newId || oldId === newId) return;
    try {
      const data = await getStorage(this.msgKey(oldId));
      if (data) {
        await setStorage(this.msgKey(newId), data);
        await removeStorage(this.msgKey(oldId));
      }
    } catch (e) {}
    const item = this.conversationList.find((c: ConversationItem) => c.id === oldId);
    if (item) {
      item.id = newId;
      await this.saveConvList();
    }
    this.conversationId = newId;
    await this.saveCurrentConvId(newId);
  }

  handleMessageClick(index: number): void {
    const now = Date.now();
    if (this.lastClickIndex === index && now - this.lastClickTime < Constants.DOUBLE_CLICK_DELAY) {
      this.lastClickTime = 0;
      this.lastClickIndex = -1;
      this.showContextMenu(index);
    } else {
      this.lastClickTime = now;
      this.lastClickIndex = index;
    }
  }

  showContextMenu(index: number): void {
    const msg = this.messages[index];
    if (!msg) return;
    this.contextMenu = {
      visible: true,
      top: 400,
      left: 200,
      msg: msg
    };
  }

  closeContextMenu(): void {
    this.contextMenu = { visible: false, top: 0, left: 0, msg: null };
  }

  handlePlayClick(): void {
    if (this.contextMenu.msg) {
      showToast('播放功能开发中');
    }
    this.closeContextMenu();
  }

  handleDeleteClick(): void {
    if (this.contextMenu.msg) {
      const idx = this.messages.indexOf(this.contextMenu.msg);
      if (idx > -1) {
        this.messages.splice(idx, 1);
      }
      this.cacheCurrentConv();
    }
    this.closeContextMenu();
  }

  refresh(): void {
    this.syncFromBackend();
  }
}

export default CompanionTab;