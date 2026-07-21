import { getStorage, setStorage } from '../utils';
import { showToast } from '../components/Toast';

const STORAGE_KEY = 'memory_cards';
const CATEGORIES = ['人生阅历', '家庭菜谱', '成长故事', '相处感悟'];

interface MemoryCard {
  id?: string;
  tag: string;
  date: string;
  title: string;
  content: string;
  author: string;
  folder_id?: string;
}

interface FormData {
  category: string;
  title: string;
  content: string;
  author: string;
}

@Component
struct MemoryTab {
  @State activeCategory: string = '人生阅历';
  @State showModalFlag: boolean = false;
  @State editMode: boolean = false;
  @State editingCard: MemoryCard | null = null;
  @State editingCardIndex: number = -1;
  @State mounted: boolean = true;
  @State loading: boolean = false;
  @State formData: FormData = {
    category: '人生阅历',
    title: '',
    content: '',
    author: '我'
  };
  @State cards: Record<string, MemoryCard[]> = {
    '人生阅历': [],
    '家庭菜谱': [],
    '成长故事': [],
    '相处感悟': []
  };
  @State _categoryFolders: Record<string, string> = {};
  @State showDeleteConfirm: boolean = false;
  @State deleteTarget: MemoryCard | null = null;
  @State deleteTargetIndex: number = -1;

  get currentCards(): MemoryCard[] {
    if (!this.cards || !this.cards[this.activeCategory]) {
      return [];
    }
    return this.cards[this.activeCategory] || [];
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        Column() {
          Text('📚 家庭记忆库')
            .fontSize(44)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4a3728');
          Text('代代相传的专属回忆与智慧 💕')
            .fontSize(26)
            .fontColor('#8ab4c9')
            .margin({ top: 8 });
        }
        .width('100%')
        .padding({ top: 40, bottom: 24, left: 30, right: 30 });

        Row() {
          this.TabItem('人生阅历', '👤 人生阅历', 0);
          this.TabItem('家庭菜谱', '🍳 家庭菜谱', 1);
          this.TabItem('成长故事', '🌱 成长故事', 2);
          this.TabItem('相处感悟', '💭 相处感悟', 3);
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 20 });

        Row() {
          Text(`[${this.activeCategory}] 相关记录 ✨`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4a3728');
          Row() {
            Text('+')
              .fontSize(28)
              .fontColor('#7a9cb8')
              .margin({ right: 6 });
            Text('录入新经验')
              .fontSize(24)
              .fontColor('#7a9cb8');
          }
          .height(56)
          .padding({ left: 20, right: 20 })
          .backgroundColor('#e8e0d5')
          .borderRadius(28)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.showModal());
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center);

        List({ space: 16 }) {
          ForEach(this.currentCards, (item: MemoryCard, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title)
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#4a3728');
                  Row() {
                    Text(item.date)
                      .fontSize(22)
                      .fontColor('#b5a899')
                      .margin({ right: 16 });
                    Text(item.author)
                      .fontSize(22)
                      .fontColor('#8ab4c9');
                  }
                  .width('100%')
                  .margin({ top: 8, bottom: 8 });
                  Text(item.content)
                    .fontSize(26)
                    .fontColor('#5a4a3a')
                    .lineHeight(32)
                    .maxLines(4)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .flexGrow(1);
                Column() {
                  Column() {
                    Text('✏️')
                      .fontSize(24);
                  }
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .backgroundColor('#e8f0f5')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .margin({ bottom: 8 })
                  .onClick(() => this.editCard(item, index));
                  Column() {
                    Text('🗑️')
                      .fontSize(24);
                  }
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .backgroundColor('#f5e8e8')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .onClick(() => this.deleteCard(item, index));
                }
                .width(60)
                .justifyContent(FlexAlign.Center);
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 20, bottom: 20 })
              .backgroundColor('#ffffff')
              .borderRadius(16)
              .borderWidth({ left: 6 })
              .borderColor('#a8c5d9');
            }
          });

          if ((this.currentCards || []).length === 0) {
            ListItem() {
              Column() {
                Text('暂无记录')
                  .fontSize(28)
                  .fontColor('#9a8b7a');
              }
              .width('100%')
              .padding({ top: 60, bottom: 60 })
              .alignItems(HorizontalAlign.Center);
            }
          }
        }
        .width('100%')
        .flexGrow(1)
        .padding({ left: 24, right: 24 })
        .scrollBar(BarState.Off);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f7f0e7')
      .padding({ bottom: 120 });

      if (this.showModalFlag) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .justifyContent(FlexAlign.End)
          .onClick(() => this.hideModal());
        Column() {
          Row() {
            Text(this.editMode ? '✏️ 编辑经验' : '📝 录入新经验')
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4a3728');
            Column() {
              Text('×')
                .fontSize(48)
                .fontColor('#a89a8a');
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.hideModal());
          }
          .width('100%')
          .padding({ left: 30, right: 30, top: 28, bottom: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center);

          Column() {
            Text('🏷️ 所属分类')
              .fontSize(28)
              .fontColor('#4a3728')
              .margin({ top: 24 });
            Row() {
              this.CategoryOption('人生阅历', '👤 人生阅历', 0);
              this.CategoryOption('家庭菜谱', '🍳 家庭菜谱', 1);
              this.CategoryOption('成长故事', '🌱 成长故事', 2);
              this.CategoryOption('相处感悟', '💭 相处感悟', 3);
            }
            .width('100%')
            .margin({ top: 12 });

            Text('📛 卡片标题')
              .fontSize(28)
              .fontColor('#4a3728')
              .margin({ top: 24 });
            TextInput({ placeholder: '请输入标题', text: this.formData.title })
              .width('100%')
              .height(88)
              .padding({ left: 24, right: 24 })
              .backgroundColor('#f5f0e8')
              .borderRadius(16)
              .fontSize(28)
              .fontColor('#4a3728')
              .placeholderColor('#b5a899')
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.formData.title = value;
              });

            Text('📝 正文内容')
              .fontSize(28)
              .fontColor('#4a3728')
              .margin({ top: 24 });
            TextArea({ placeholder: '请输入内容', text: this.formData.content })
              .width('100%')
              .height(150)
              .padding({ left: 24, right: 24, top: 20, bottom: 20 })
              .backgroundColor('#f5f0e8')
              .borderRadius(16)
              .fontSize(28)
              .fontColor('#4a3728')
              .placeholderColor('#b5a899')
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.formData.content = value;
              });

            Text('👤 作者')
              .fontSize(28)
              .fontColor('#4a3728')
              .margin({ top: 24 });
            TextInput({ placeholder: '请输入作者', text: this.formData.author })
              .width('100%')
              .height(88)
              .padding({ left: 24, right: 24 })
              .backgroundColor('#f5f0e8')
              .borderRadius(16)
              .fontSize(28)
              .fontColor('#4a3728')
              .placeholderColor('#b5a899')
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.formData.author = value || '我';
              });

            Column() {
              Text('保存')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff');
            }
            .width('100%')
            .height(96)
            .margin({ top: 32 })
            .backgroundColor('#a8c5d9')
            .borderRadius(48)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => this.saveCard());
          }
          .width('100%')
          .padding({ left: 30, right: 30 });
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius({ topLeft: 32, topRight: 32 })
        .padding({ top: 32, bottom: 128 });
      }

      if (this.showDeleteConfirm) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => this.cancelDelete());
        Column() {
          Text('确认删除')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4a3728')
            .margin({ bottom: 12 });
          Text(`删除后不可恢复，确定要删除「${this.deleteTarget ? this.deleteTarget.title : ''}」吗？`)
            .fontSize(26)
            .fontColor('#9a8b7a')
            .textAlign(TextAlign.Center)
            .lineHeight(36)
            .margin({ bottom: 28 });
          Row() {
            Column() {
              Text('取消')
                .fontSize(28)
                .fontColor('#9a8b7a');
            }
            .width(200)
            .height(72)
            .backgroundColor('#f0e8dd')
            .borderRadius(36)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ right: 12 })
            .onClick(() => this.cancelDelete());
            Column() {
              Text('删除')
                .fontSize(28)
                .fontColor('#ffffff');
            }
            .width(200)
            .height(72)
            .backgroundColor('#e07070')
            .borderRadius(36)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ left: 12 })
            .onClick(() => this.confirmDelete());
          }
          .width('100%');
        }
        .width(560)
        .backgroundColor('#ffffff')
        .borderRadius(20)
        .padding({ top: 36, bottom: 28, left: 32, right: 32 })
        .alignItems(HorizontalAlign.Center)
        .onClick((event: ClickEvent) => {
          event.preventDefault();
        });
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder TabItem(category: string, label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(24)
        .fontColor(this.activeCategory === category ? '#ffffff' : '#6b5a4a');
    }
    .flexGrow(1)
    .height(72)
    .backgroundColor(this.activeCategory === category ? '#a8c5d9' : '#ffffff')
    .borderRadius(36)
    .margin({ left: index === 0 ? 0 : 12 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.switchCategory(category));
  }

  @Builder CategoryOption(category: string, label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(24)
        .fontColor(this.formData.category === category ? '#ffffff' : '#4a3728');
    }
    .flexGrow(1)
    .height(72)
    .backgroundColor(this.formData.category === category ? '#a8c5d9' : '#f5f0e8')
    .borderRadius(16)
    .margin({ left: index === 0 ? 0 : 12 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.selectCategory(category));
  }

  aboutToAppear(): void {
    this.mounted = true;
    this.cards = { '人生阅历': [], '家庭菜谱': [], '成长故事': [], '相处感悟': [] };
    this.activeCategory = '人生阅历';
    this._categoryFolders = {};
    this.loadAll();
  }

  aboutToDisappear(): void {
    this.mounted = false;
  }

  async loadAll(): Promise<void> {
    if (!this.mounted) return;
    this.loading = true;
    try {
      await this.ensureCategoryFolders();
      await this.loadCards();
    } catch (e) {
      console.log('后端加载失败，回退本地缓存:', e);
      this.loadFromCache();
    }
    this.loading = false;
  }

  async ensureCategoryFolders(): Promise<void> {
    if (!this.mounted) return;
    this._categoryFolders = {};
  }

  async loadCards(): Promise<void> {
    if (!this.mounted) return;
    const grouped: Record<string, MemoryCard[]> = {};
    CATEGORIES.forEach(cat => { grouped[cat] = []; });
    this.cards = grouped;
    this.saveToCache();
  }

  loadFromCache(): void {
    if (!this.mounted) return;
    getStorage(STORAGE_KEY).then((data) => {
      if (!this.mounted) return;
      if (data && typeof data === 'object') {
        CATEGORIES.forEach(cat => {
          if ((data as Record<string, MemoryCard[]>)[cat]) {
            this.cards[cat] = (data as Record<string, MemoryCard[]>)[cat];
          }
        });
      }
    }).catch(() => {});
  }

  saveToCache(): void {
    if (!this.mounted) return;
    setStorage(STORAGE_KEY, this.cards).catch(() => {});
  }

  switchCategory(category: string): void {
    if (!this.mounted) return;
    this.activeCategory = category;
  }

  selectCategory(category: string): void {
    if (!this.mounted) return;
    this.formData.category = category;
  }

  showModal(): void {
    if (!this.mounted) return;
    this.editMode = false;
    this.editingCard = null;
    this.editingCardIndex = -1;
    this.formData = { category: '人生阅历', title: '', content: '', author: '我' };
    this.showModalFlag = true;
  }

  editCard(card: MemoryCard, index: number): void {
    if (!this.mounted) return;
    this.editMode = true;
    this.editingCard = card;
    this.editingCardIndex = index;
    this.formData = {
      category: card.tag || '人生阅历',
      title: card.title || '',
      content: card.content || '',
      author: card.author || '我'
    };
    this.showModalFlag = true;
  }

  hideModal(): void {
    if (!this.mounted) return;
    this.showModalFlag = false;
    this.editMode = false;
    this.editingCard = null;
    this.editingCardIndex = -1;
  }

  saveCard(): void {
    if (!this.mounted) return;
    if (!this.formData.title || !this.formData.content) {
      showToast('请填写完整信息');
      return;
    }
    if (this.editMode) {
      this.doUpdateCard();
    } else {
      this.doCreateCard();
    }
  }

  doCreateCard(): void {
    if (!this.mounted) return;
    const cat = this.formData.category;
    const folderId = this._categoryFolders[cat] || undefined;
    const card: MemoryCard = {
      tag: cat,
      date: new Date().toLocaleDateString('zh-CN').replace(/\//g, '.'),
      title: this.formData.title,
      content: this.formData.content,
      author: this.formData.author || '我',
      folder_id: folderId
    };
    this.cards[cat].unshift(card);
    this.saveToCache();
    this.hideModal();
    showToast('保存成功');
  }

  doUpdateCard(): void {
    if (!this.mounted) return;
    const card = this.editingCard;
    const index = this.editingCardIndex;
    if (!card || index < 0) return;

    const oldTag = card.tag;
    const newTag = this.formData.category;

    card.title = this.formData.title;
    card.content = this.formData.content;
    card.author = this.formData.author || '我';
    card.tag = newTag;

    if (newTag !== oldTag) {
      this.cards[oldTag].splice(index, 1);
      this.cards[newTag].unshift(card);
    }

    this.saveToCache();
    this.hideModal();
    showToast('保存成功');
  }

  deleteCard(card: MemoryCard, index: number): void {
    if (!this.mounted) return;
    this.deleteTarget = card;
    this.deleteTargetIndex = index;
    this.showDeleteConfirm = true;
  }

  cancelDelete(): void {
    if (!this.mounted) return;
    this.showDeleteConfirm = false;
    this.deleteTarget = null;
    this.deleteTargetIndex = -1;
  }

  confirmDelete(): void {
    if (!this.mounted) return;
    const card = this.deleteTarget;
    const index = this.deleteTargetIndex;
    const cat = card ? card.tag || '人生阅历' : '人生阅历';

    if (card && index >= 0) {
      this.cards[cat].splice(index, 1);
      this.saveToCache();
    }

    this.showDeleteConfirm = false;
    this.deleteTarget = null;
    this.deleteTargetIndex = -1;
    showToast('已删除');
  }

  refresh(): void {
    if (this.mounted) this.loadAll();
  }
}

export default MemoryTab;