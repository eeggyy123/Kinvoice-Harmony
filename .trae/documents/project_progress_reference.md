# KinVoice 鸿蒙项目开发进度参考文档

> 文档版本：v1.0  
> 生成日期：2026-07-22  
> 项目路径：`e:\workspace\stm32\robocup\KinVoice-xue\Huawei-programming\KinVoice`

---

## 一、当前已完成的开发进度

### 1.1 项目基础架构
- ✅ Stage模型工程结构搭建完成
- ✅ 四大核心Tab组件（CompanionTab、BreakIceTab、MemoryTab、ProfileTab）移植完成
- ✅ 页面路由配置（main_pages.json）完成
- ✅ 底部导航栏（Tabbar）实现完成
- ✅ 网络请求封装（http.ts、api.ts）完成

### 1.2 功能模块
| 模块 | 状态 | 说明 |
|------|------|------|
| 陪伴聊天（CompanionTab） | ✅ 完成 | AI对话、消息发送/接收、语音播放入口 |
| 破冰聊天（BreakIceTab） | ✅ 完成 | 家庭组列表、聊天会话、NVC转换 |
| 家庭记忆库（MemoryTab） | ✅ 完成 | 分类记忆卡片、增删改查、本地缓存 |
| 用户档案（ProfileTab） | ✅ 完成 | 用户信息展示、设置、家庭管理 |

### 1.3 鸿蒙特性基础框架
| 特性 | 状态 | 说明 |
|------|------|------|
| 互动卡片（KinVoiceCard） | ⚠️ 基础 | 静态卡片组件，需增强动态数据 |
| 空间音频（AudioService） | ⚠️ 基础 | 播放器框架，需实现TTS和空间音效 |
| Agent能力（Skill Schema） | ⚠️ 基础 | 配置文件，需实现Skill Ability |
| 数据备份（EntryBackupAbility） | ⚠️ 基础 | 空框架，需实现备份逻辑 |

---

## 二、关键功能实现细节

### 2.1 四大核心Tab组件

#### CompanionTab（陪伴聊天）
- **文件路径**: `entry/src/main/ets/components/CompanionTab.ets`
- **核心功能**: AI对话、消息发送/接收、语音合成播放入口
- **状态管理**: 
  - `@State messages`: 消息列表数组
  - `@State inputText`: 输入框文本
  - `@State loading`: 加载状态
- **关键方法**: 
  - `sendMessage()`: 发送消息到后端
  - `playVoice()`: 播放语音合成

#### BreakIceTab（破冰聊天）
- **文件路径**: `entry/src/main/ets/components/BreakIceTab.ets`
- **核心功能**: 家庭组状态、聊天会话列表、NVC转换
- **状态管理**: 
  - `@State pinnedConvs`: 置顶会话列表
  - `@State otherConvs`: 其他会话列表
- **关键方法**: 
  - `openChat()`: 打开聊天页面
  - `convertToNVC()`: 转换为非暴力沟通表达

#### MemoryTab（家庭记忆库）
- **文件路径**: `entry/src/main/ets/components/MemoryTab.ets`
- **核心功能**: 分类记忆卡片、增删改查、本地缓存
- **状态管理**: 
  - `@State activeCategory`: 当前分类
  - `@State cards`: 分类卡片映射 `Record<string, MemoryCard[]>`
  - `@State showModalFlag`: 弹窗显示状态
- **关键方法**: 
  - `loadAll()`: 加载所有卡片
  - `loadFromCache()`: 从本地缓存加载
  - `saveToCache()`: 保存到本地缓存

#### ProfileTab（用户档案）
- **文件路径**: `entry/src/main/ets/components/ProfileTab.ets`
- **核心功能**: 用户信息、设置、家庭管理
- **状态管理**: 
  - `@State userProfile`: 用户资料
  - `@State expandedSection`: 展开的设置项

### 2.2 网络请求封装

#### http.ts
- **文件路径**: `entry/src/main/ets/services/http.ts`
- **核心功能**: 统一HTTP请求封装
- **关键类**: `HttpService`（单例模式）
- **方法**: `get()`, `post()`, `put()`, `delete()`
- **基础URL**: `http://localhost:8000`

#### api.ts
- **文件路径**: `entry/src/main/ets/services/api.ts`
- **核心功能**: 业务API接口封装
- **API类**: 
  - `ChatAPI`: 聊天相关接口
  - `NVCAPI`: NVC转换接口
  - `MemoryAPI`: 记忆卡片接口
  - `ProfileAPI`: 用户档案接口
  - `FamilyAPI`: 家庭组接口

### 2.3 鸿蒙特性框架

#### KinVoiceCard（互动卡片）
- **文件路径**: `entry/src/main/ets/widget/KinVoiceCard.ets`
- **配置文件**: `entry/src/main/resources/base/profile/KinVoiceCard.json`
- **当前状态**: 静态卡片，显示固定问候语
- **待增强**: 动态数据绑定、点击跳转、多尺寸支持

#### AudioService（空间音频）
- **文件路径**: `entry/src/main/ets/services/audio.ts`
- **当前状态**: 基础播放器框架，`synthesizeSpeech()` 返回模拟数据
- **待增强**: 集成鸿蒙TTS API、空间音频效果

#### Skill Schema（Agent能力）
- **配置文件**: `entry/src/main/resources/base/profile/skill_config.json`
- **当前状态**: 定义了两个Skill（KinVoiceChatSkill、KinVoiceNVCConvertSkill）
- **待增强**: 创建Skill Ability组件

#### EntryBackupAbility（数据备份）
- **文件路径**: `entry/src/main/ets/entrybackupability/EntryBackupAbility.ets`
- **当前状态**: 空框架，仅实现接口
- **待增强**: 实现完整备份策略

---

## 三、遇到的问题及解决方案

### 3.1 编译错误

| 错误类型 | 错误码 | 解决方案 |
|----------|--------|----------|
| 类型转换语法错误 | 10605053 | `<string>val` → `val as string` |
| 组件标签语法错误 | 10905204 | `<Component/>` → `<Component />`（斜杠前加空格） |
| 对象字面量无类型 | 10605038 | 定义显式interface约束对象结构 |
| 扩展运算符不支持 | 10605099 | `{...obj}` → `Object.assign()` 或逐字段赋值 |
| 标准库受限 | 10605144 | 替换为鸿蒙系统API（`@ohos.util`） |

### 3.2 API废弃/参数不匹配

| API | 错误 | 解决方案 |
|-----|------|----------|
| `List.paddingBottom()` | 不存在 | 移至父容器Column添加padding |
| `ClickEvent.stopPropagation()` | 不存在 | 替换为 `event.preventDefault()` |
| `TransitionType.Translate` | 不存在 | 使用 `TransitionEffect.Translate()` |
| `scale(1)` | 参数不匹配 | 使用 `scale({ x: 1, y: 1 })` |

### 3.3 运行时错误

| 错误 | 文件 | 解决方案 |
|------|------|----------|
| `Cannot read property length of undefined` | MemoryTab.ets:76 | 添加可选链 `?.` 和默认值 `|| []` |
| 预览空白 | Main.ets | 修复组件标签语法后恢复正常 |

---

## 四、待完成的任务清单

### 4.1 鸿蒙特性实现（高优先级）

| 任务 | 优先级 | 状态 | 描述 |
|------|--------|------|------|
| 完善互动卡片 | high | pending | 动态数据绑定、点击跳转、多尺寸 |
| 实现空间音频 | high | pending | TTS语音合成、3D空间音效 |
| 实现Agent能力 | high | pending | Skill Ability、Intent处理 |
| 实现数据备份 | medium | pending | 备份策略、数据加密 |

### 4.2 代码优化（中优先级）

| 任务 | 优先级 | 状态 | 描述 |
|------|--------|------|------|
| 增强卡片样式 | medium | pending | 动态问候语、家庭状态展示 |
| 添加语音播放按钮 | medium | pending | 在CompanionTab中添加语音图标 |
| 优化卡片交互 | medium | pending | 点击不同区域跳转到对应页面 |
| 完善错误处理 | medium | pending | 网络异常、权限申请失败 |

### 4.3 测试与验证（中优先级）

| 任务 | 优先级 | 状态 | 描述 |
|------|--------|------|------|
| 编译验证 | medium | pending | 确保无编译错误 |
| 预览测试 | medium | pending | 验证所有特性正常工作 |
| 功能测试 | medium | pending | 手动测试核心功能 |

---

## 五、代码结构说明

```
entry/src/main/ets/
├── components/           # 自定义组件
│   ├── BreakIceTab.ets   # 破冰聊天Tab
│   ├── CompanionTab.ets  # 陪伴聊天Tab
│   ├── MemoryTab.ets     # 家庭记忆库Tab
│   ├── ProfileTab.ets    # 用户档案Tab
│   ├── Tabbar.ets        # 底部导航栏
│   ├── Dialog.ets        # 弹窗组件
│   ├── Loading.ets       # 加载组件
│   └── Toast.ets         # 提示组件
├── pages/                # 页面路由
│   ├── Main.ets          # 首页容器
│   ├── BreakIce.ets      # 破冰聊天页面
│   ├── ChatRoom.ets      # 聊天室页面
│   ├── Memory.ets        # 记忆库页面
│   ├── Profile.ets       # 档案页面
│   └── ProfileDetail.ets # 档案详情页面
├── services/             # 服务层
│   ├── api.ts            # API接口封装
│   ├── http.ts           # HTTP请求封装
│   └── audio.ts          # 音频服务
├── entryability/         # 应用入口
│   └── EntryAbility.ets  # 主Ability
├── entrybackupability/   # 备份能力
│   └── EntryBackupAbility.ets
├── widget/               # 卡片组件
│   └── KinVoiceCard.ets  # 互动卡片
└── utils/                # 工具类
    └── index.ts          # 通用工具函数
```

---

## 六、重要变量和函数说明

### 6.1 全局常量

| 常量 | 文件 | 说明 |
|------|------|------|
| `STORAGE_KEY` | MemoryTab.ets | 本地存储键名 `'memory_cards'` |
| `CATEGORIES` | MemoryTab.ets | 记忆分类数组 `['人生阅历', '家庭菜谱', '成长故事', '相处感悟']` |
| `BASE_URL` | http.ts | 后端API地址 `http://localhost:8000` |

### 6.2 核心接口

| 接口 | 文件 | 说明 |
|------|------|------|
| `ChatMessage` | api.ts | 聊天消息结构 `{ role, content, created_at }` |
| `Conversation` | api.ts | 会话结构 `{ id, title, created_at }` |
| `MemoryCard` | api.ts | 记忆卡片结构 `{ id, title, content, category }` |
| `NVCPrompt` | api.ts | NVC提示结构 `{ observation, feeling, need, request }` |
| `APIResponse<T>` | api.ts | 统一响应结构 `{ success, code, message, data }` |

### 6.3 关键函数

| 函数 | 文件 | 说明 |
|------|------|------|
| `sendMessage()` | CompanionTab.ets | 发送聊天消息 |
| `loadAll()` | MemoryTab.ets | 加载所有记忆卡片 |
| `saveToCache()` | MemoryTab.ets | 保存到本地缓存 |
| `loadFromCache()` | MemoryTab.ets | 从本地缓存加载 |
| `convertToNVC()` | BreakIceTab.ets | NVC转换 |
| `playTextToSpeech()` | audio.ts | 语音合成播放 |

---

## 七、后续开发建议

### 7.1 开发顺序建议

1. **第一步**: 完善互动卡片（KinVoiceCard）
   - 添加动态问候语（根据时间变化）
   - 添加点击跳转功能
   - 更新配置文件支持多尺寸

2. **第二步**: 实现空间音频
   - 集成鸿蒙TTS API（`@kit.MultimediaKit`）
   - 在CompanionTab添加语音播放按钮
   - 实现空间音频效果

3. **第三步**: 实现Agent能力
   - 创建SkillAbility.ets
   - 完善skill_config.json
   - 在module.json5注册Skill

4. **第四步**: 实现数据备份
   - 完善EntryBackupAbility.ets
   - 实现备份策略（定时备份、手动备份）
   - 处理数据加密

### 7.2 注意事项

1. **ArkTS强类型规范**:
   - 禁止使用 `any`/`unknown` 类型
   - 所有对象字面量必须绑定显式interface
   - 类型转换使用 `as` 语法

2. **API兼容性**:
   - List组件不支持paddingBottom/paddingTop
   - ClickEvent使用preventDefault代替stopPropagation
   - scale参数为对象形式 `{ x, y }`

3. **状态管理**:
   - 使用 `@State` 管理组件内部状态
   - 异步数据加载后及时更新状态
   - 列表渲染变量初始化时赋予空数组 `[]`

4. **测试验证**:
   - 每次修改后运行构建命令验证编译
   - 使用DevEco Studio预览验证功能
   - 确保后端服务正常运行（http://localhost:8000）

---

## 八、快速参考

### 8.1 构建命令

```bash
# 进入项目目录
cd Huawei-programming/KinVoice

# 构建HAP文件
.\gradlew.bat assembleDebug

# 或使用hvigor
.\hvigorw.bat assembleHap
```

### 8.2 后端启动

```bash
cd backend
python start.py
# 或
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 8.3 关键配置文件

| 文件 | 路径 | 说明 |
|------|------|------|
| 应用配置 | `entry/src/main/module.json5` | 能力注册、权限配置 |
| 卡片配置 | `entry/src/main/resources/base/profile/KinVoiceCard.json` | 互动卡片配置 |
| Skill配置 | `entry/src/main/resources/base/profile/skill_config.json` | Agent能力配置 |
| 页面路由 | `entry/src/main/resources/base/profile/main_pages.json` | 页面路由配置 |

---

**文档结束** - 祝你在新文件夹中开发顺利！如有问题可随时参考此文档。