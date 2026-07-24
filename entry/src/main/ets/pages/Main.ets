import BreakIceTab from '../components/BreakIceTab';
import MemoryTab from '../components/MemoryTab';
import ProfileTab from '../components/ProfileTab';
import CompanionTab from '../components/CompanionTab';
import Tabbar from '../components/Tabbar';

@Entry
@Component
struct Main {
  @State activeTab: string = 'companion';
  @State showCount: number = 0;
  @State refreshTrigger: number = 0;

  build() {
    Column() {
      this.RenderContent();
      Tabbar({ activeTab: this.activeTab, onTabChange: (key: string) => this.onTabChange(key) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#e8e4df');
  }

  @Builder RenderContent() {
    if (this.activeTab === 'companion') {
      CompanionTab({ refreshTrigger: this.refreshTrigger });
    } else if (this.activeTab === 'breakIce') {
      BreakIceTab({ refreshTrigger: this.refreshTrigger });
    } else if (this.activeTab === 'memory') {
      MemoryTab({ refreshTrigger: this.refreshTrigger });
    } else if (this.activeTab === 'profile') {
      ProfileTab({ refreshTrigger: this.refreshTrigger });
    }
  }

  onShow(): void {
    this.showCount++;
    if (this.showCount > 1) {
      this.refreshCurrentTab();
    }
  }

  onTabChange(key: string): void {
    if (!key || key === this.activeTab) return;
    this.activeTab = key;
  }

  refreshCurrentTab(): void {
    this.refreshTrigger++;
  }
}