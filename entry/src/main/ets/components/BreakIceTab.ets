import { FamilyAPI, ChatAPI } from '../services/api';
import { showToast } from '../components/Toast';

interface RawConversation {
  id?: number;
  type: string;
  peer_user_id?: string;
  peer_nickname?: string;
  title?: string;
  last_message?: string;
  last_time?: string;
  _pinned?: boolean;
  _avatarText?: string;
  _displayName?: string;
  _preview?: string;
  _timeText?: string;
  _isVirtual?: boolean;
}

interface ConversationItem {
  id?: number;
  type: string;
  _pinned: boolean;
  _avatarText: string;
  _displayName: string;
  _preview: string;
  _timeText: string;
  _isVirtual?: boolean;
  peer_user_id?: string;
  peer_nickname?: string;
  title?: string;
  last_time?: string;
}

@Component
struct BreakIceTab {
  @State familyId: string = '';
  @State myUserId: string = '';
  @State loading: boolean = true;
  @State loadingData: boolean = false;
  @State rawConvs: RawConversation[] = [];
  @State mounted: boolean = true;

  get sortedConvs(): ConversationItem[] {
    const list: ConversationItem[] = (this.rawConvs || []).map((conv: RawConversation) => {
      const isGroup = conv.type === 'group';
      const peerName = (conv && typeof conv.peer_nickname === 'string') ? conv.peer_nickname : '';
      const initial = peerName ? peerName.charAt(0).toUpperCase() : '?';
      const item: ConversationItem = {
        id: conv.id,
        type: conv.type,
        _pinned: isGroup,
        _avatarText: isGroup ? '👥' : initial,
        _displayName: isGroup
          ? (conv.title || '家庭群聊')
          : (conv.peer_nickname || '未知'),
        _preview: conv.last_message || '暂无消息',
        _timeText: this.formatChatTime(conv.last_time),
        _isVirtual: conv._isVirtual,
        peer_user_id: conv.peer_user_id,
        peer_nickname: conv.peer_nickname,
        title: conv.title,
        last_time: conv.last_time,
      };
      return item;
    });

    if (this.familyId) {
      const hasGroupConv = list.some((c: ConversationItem) => c.type === 'group');
      if (!hasGroupConv) {
        list.push({
          type: 'group',
          title: '家庭群聊',
          _pinned: true,
          _isVirtual: true,
          _avatarText: '👥',
          _displayName: '家庭群聊',
          _preview: '点击进入群聊，发送第一条消息',
          _timeText: '',
        });
      }
    }

    list.sort((a: ConversationItem, b: ConversationItem) => {
      if (a._pinned && !b._pinned) return -1;
      if (!a._pinned && b._pinned) return 1;
      const ta = a.last_time ? new Date(a.last_time).getTime() : 0;
      const tb = b.last_time ? new Date(b.last_time).getTime() : 0;
      return tb - ta;
    });

    return list;
  }

  get pinnedConvs(): ConversationItem[] {
    return this.sortedConvs.filter((conv: ConversationItem) => conv._pinned);
  }

  get normalConvs(): ConversationItem[] {
    return this.sortedConvs.filter((conv: ConversationItem) => !conv._pinned);
  }

  build() {
    Column({ space: 0 }) {
      Column() {
        Text('聊天')
          .fontSize(44)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4a3728');
      }
      .width('100%')
      .padding({ top: 60, bottom: 20, left: 30, right: 30 })
      .backgroundColor('#f7f0e7');

      Column() {
        List({ space: 0 }) {
          if (this.loading) {
            ListItem() {
              Column() {
                Text('加载中...')
                  .fontSize(26)
                  .fontColor('#9a8b7a');
              }
              .width('100%')
              .padding({ top: 60, bottom: 60 })
              .alignItems(HorizontalAlign.Center);
            }
          } else if (!this.familyId) {
            ListItem() {
              Column() {
                Text('🏠')
                  .fontSize(56)
                  .margin({ bottom: 12 });
                Text('你还没有加入家庭组')
                  .fontSize(28)
                  .fontColor('#4a3728')
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 6 });
                Text('加入家庭组后即可与家人聊天')
                  .fontSize(24)
                  .fontColor('#9a8b7a')
                  .margin({ bottom: 20 });
                Column() {
                  Text('去加入家庭组')
                    .fontSize(26)
                    .fontColor('#ffffff');
                }
                .width(300)
                .height(60)
                .backgroundColor('#d4874b')
                .borderRadius(10)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => this.goFamily());
              }
              .width('100%')
              .padding({ top: 60, bottom: 60, left: 30, right: 30 })
              .margin({ top: 20 })
              .backgroundColor('#faf8f5')
              .borderRadius(16)
              .alignItems(HorizontalAlign.Center);
            }
          } else if (this.sortedConvs.length === 0) {
            ListItem() {
              Column() {
                Text('💬')
                  .fontSize(56)
                  .margin({ bottom: 12 });
                Text('暂无聊天')
                  .fontSize(28)
                  .fontColor('#4a3728')
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 6 });
                Text('等待家庭组成员发起聊天')
                  .fontSize(24)
                  .fontColor('#9a8b7a');
              }
              .width('100%')
              .padding({ top: 60, bottom: 60, left: 30, right: 30 })
              .margin({ top: 20 })
              .backgroundColor('#faf8f5')
              .borderRadius(16)
              .alignItems(HorizontalAlign.Center);
            }
          } else {
            if (this.pinnedConvs.length > 0) {
              ListItem() {
                Text('置顶聊天')
                  .fontSize(22)
                  .fontColor('#bfb5a8')
                  .padding({ top: 14, bottom: 6, left: 4, right: 4 })
                  .margin({ top: 8 });
              }
            }

            ForEach(this.pinnedConvs, (conv: ConversationItem) => {
              ListItem() {
                this.ConversationItemUI(conv);
              }
            }, (conv: ConversationItem) => JSON.stringify(conv));

            ForEach(this.normalConvs, (conv: ConversationItem) => {
              ListItem() {
                this.ConversationItemUI(conv);
              }
            }, (conv: ConversationItem) => JSON.stringify(conv));
          }
        }
        .width('100%')
        .flexGrow(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off);
      }
      .width('100%')
      .flexGrow(1)
      .padding({ bottom: 96 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f7f0e7');
  }

  @Builder ConversationItemUI(conv: ConversationItem) {
    Row() {
      Column() {
        Text(conv._avatarText)
          .fontSize(32)
          .fontColor('#ffffff')
          .fontWeight(FontWeight.Bold);
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor(conv.type === 'group' ? '#8ab4c9' : '#d4874b')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .flexShrink(0);

      Column() {
        Text(conv._displayName)
          .fontSize(30)
          .fontColor('#4a3728')
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 6 });
        Text(conv._preview)
          .fontSize(24)
          .fontColor('#9a8b7a')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .flexGrow(1)
      .margin({ left: 16 });

      Column() {
        Text(conv._timeText)
          .fontSize(22)
          .fontColor('#bfb5a8')
          .margin({ right: 4 });
        Text('›')
          .fontSize(30)
          .fontColor('#bfb5a8');
      }
      .justifyContent(FlexAlign.Center)
      .margin({ left: 10 })
      .flexShrink(0);
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 20, bottom: 20 })
    .backgroundColor(conv._pinned ? '#f0ebe2' : '#faf8f5')
    .borderRadius(14)
    .margin({ bottom: 6 })
    .onClick(() => this.openChat(conv));
  }

  formatChatTime(isoStr?: string): string {
    if (!isoStr) return '';
    const date = new Date(isoStr);
    const now = new Date();
    if (isNaN(date.getTime())) return '';

    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterdayStart = new Date(todayStart.getTime() - 86400000);
    const dateStart = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    if (dateStart.getTime() >= todayStart.getTime()) {
      const hh = String(date.getHours()).padStart(2, '0');
      const mm = String(date.getMinutes()).padStart(2, '0');
      return `${hh}:${mm}`;
    }
    if (dateStart.getTime() >= yesterdayStart.getTime()) {
      return '昨天';
    }
    const weekAgo = new Date(todayStart.getTime() - 6 * 86400000);
    if (dateStart.getTime() >= weekAgo.getTime()) {
      const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return days[date.getDay()];
    }
    if (date.getFullYear() === now.getFullYear()) {
      return `${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}`;
    }
    return `${date.getFullYear()}/${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}`;
  }

  aboutToAppear(): void {
    this.mounted = true;
    this.familyId = '';
    this.myUserId = '';
    this.rawConvs = [];
    this.loading = true;
    this.loadingData = false;
    this.loadData();
  }

  aboutToDisappear(): void {
    this.mounted = false;
  }

  async loadData(): Promise<void> {
    this.loadingData = true;
    this.loading = true;
    try {
      const famRes = await FamilyAPI.getMyGroup();
      if (!this.mounted) return;
      if (famRes.data && famRes.data.family_id) {
        this.familyId = famRes.data.family_id;
      } else {
        this.familyId = '';
      }

      if (this.familyId) {
        const convRes = await ChatAPI.listConversations();
        if (!this.mounted) return;
        if (convRes.success && convRes.data.conversations) {
          this.rawConvs = convRes.data.conversations.map((c: { id: number; title: string; updated_at?: string; last_message?: string }) => ({
            id: c.id,
            type: 'group',
            title: c.title || '家庭群聊',
            last_message: c.last_message || '',
            last_time: c.updated_at || '',
          }));
        } else {
          this.rawConvs = [];
        }
      } else {
        this.rawConvs = [];
      }
    } catch (e) {
      console.log('加载聊天列表失败:', e);
      this.rawConvs = [];
    } finally {
      if (this.mounted) {
        this.loading = false;
        this.loadingData = false;
      }
    }
  }

  openChat(conv: ConversationItem): void {
    if (conv.type === 'group') {
      showToast('群聊功能开发中');
    } else {
      const peerId = conv.peer_user_id || '';
      const peerName = conv.peer_nickname || '';
      showToast(`打开与 ${peerName} 的聊天`);
    }
  }

  goFamily(): void {
    showToast('家庭组功能开发中');
  }

  refresh(): void {
    if (this.mounted && this.myUserId && !this.loadingData) {
      this.loadData();
    }
  }
}

export default BreakIceTab;