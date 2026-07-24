# KinVoice API 接口文档

## 一、基础信息

| 项目 | 内容 |
|------|------|
| **基础URL** | `http://localhost:8000/api/v1` |
| **协议** | HTTP/HTTPS |
| **数据格式** | JSON |
| **字符编码** | UTF-8 |
| **跨域支持** | 支持 CORS |

## 二、响应格式

### 2.1 成功响应

```json
{
  "success": true,
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

### 2.2 失败响应

```json
{
  "success": false,
  "code": 400,
  "message": "错误描述",
  "data": null
}
```

### 2.3 错误码说明

| 错误码 | 含义 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 三、接口列表

### 3.1 聊天接口 (Chat)

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 发送消息 | POST | `/chat` | 向AI发送消息并获取回复 |
| 获取对话历史 | GET | `/chat/history/{id}` | 获取指定对话的消息历史 |
| 获取对话列表 | GET | `/chat/conversations` | 获取用户所有对话列表 |
| 删除对话 | DELETE | `/chat/conversations/{id}` | 删除指定对话 |

#### 3.1.1 发送消息

**请求**
```
POST /chat
```

**请求体**
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户消息内容 |
| conversation_id | number | 否 | 对话ID，新建传null |
| family_id | string | 否 | 家庭组ID |

**示例**
```json
{
  "message": "今天过得怎么样？",
  "conversation_id": null,
  "family_id": "family_001"
}
```

**响应**
| 字段 | 类型 | 说明 |
|------|------|------|
| reply | string | AI回复内容 |
| conversation_id | number | 对话ID |
| messages | ChatMessage[] | 消息列表 |

```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "reply": "我很好，谢谢你的关心！今天有什么想聊的吗？",
    "conversation_id": 12345,
    "messages": []
  }
}
```

#### 3.1.2 获取对话历史

**请求**
```
GET /chat/history/{conversation_id}
```

**路径参数**
| 参数 | 类型 | 说明 |
|------|------|------|
| conversation_id | number | 对话ID |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "messages": [
      {
        "id": "msg_001",
        "role": "user",
        "content": "你好",
        "created_at": "2026-07-24T10:00:00Z"
      },
      {
        "id": "msg_002",
        "role": "assistant",
        "content": "你好！我是Cloudie，很高兴认识你！",
        "created_at": "2026-07-24T10:00:05Z"
      }
    ]
  }
}
```

#### 3.1.3 获取对话列表

**请求**
```
GET /chat/conversations
```

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "conversations": [
      {
        "id": 12345,
        "title": "今天过得怎么样？",
        "created_at": "2026-07-24T10:00:00Z",
        "updated_at": "2026-07-24T10:05:00Z"
      }
    ]
  }
}
```

#### 3.1.4 删除对话

**请求**
```
DELETE /chat/conversations/{conversation_id}
```

**路径参数**
| 参数 | 类型 | 说明 |
|------|------|------|
| conversation_id | number | 对话ID |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "已删除",
  "data": {}
}
```

---

### 3.2 NVC转换接口

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| NVC转换 | POST | `/nvc/convert` | 将攻击性话语转换为温和表达 |

#### 3.2.1 NVC转换

**请求**
```
POST /nvc/convert
```

**请求体**
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| text | string | 是 | 需要转换的原始文本 |

**示例**
```json
{
  "text": "你总是不理解我！"
}
```

**响应**
| 字段 | 类型 | 说明 |
|------|------|------|
| nvc_expression | string | NVC转换后的表达 |
| prompt.observation | string | 观察 |
| prompt.feeling | string | 感受 |
| prompt.need | string | 需要 |
| prompt.request | string | 请求 |

```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "nvc_expression": "当我看到我们的沟通不太顺畅时，我感到有些难过，因为我非常看重被理解的感觉。你愿意和我一起试着更好地理解彼此吗？",
    "prompt": {
      "observation": "我们的沟通不太顺畅",
      "feeling": "难过",
      "need": "被理解",
      "request": "一起试着更好地理解彼此"
    }
  }
}
```

---

### 3.3 记忆库接口 (Memory)

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 获取卡片列表 | GET | `/memory/cards` | 获取所有记忆卡片 |
| 获取单张卡片 | GET | `/memory/cards/{id}` | 获取指定卡片详情 |
| 创建卡片 | POST | `/memory/cards` | 创建新的记忆卡片 |
| 更新卡片 | PUT | `/memory/cards/{id}` | 更新指定卡片 |
| 删除卡片 | DELETE | `/memory/cards/{id}` | 删除指定卡片 |

#### 3.3.1 获取卡片列表

**请求**
```
GET /memory/cards
```

**查询参数**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | string | 否 | 分类筛选 |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "cards": [
      {
        "id": "card_001",
        "title": "爷爷的红烧肉",
        "content": "爷爷做的红烧肉秘诀：先炸后炖，冰糖上色...",
        "category": "家庭菜谱",
        "created_at": "2026-07-24T10:00:00Z",
        "updated_at": "2026-07-24T10:00:00Z"
      }
    ]
  }
}
```

#### 3.3.2 获取单张卡片

**请求**
```
GET /memory/cards/{card_id}
```

**路径参数**
| 参数 | 类型 | 说明 |
|------|------|------|
| card_id | string | 卡片ID |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "id": "card_001",
    "title": "爷爷的红烧肉",
    "content": "爷爷做的红烧肉秘诀：先炸后炖，冰糖上色...",
    "category": "家庭菜谱",
    "created_at": "2026-07-24T10:00:00Z",
    "updated_at": "2026-07-24T10:00:00Z"
  }
}
```

#### 3.3.3 创建卡片

**请求**
```
POST /memory/cards
```

**请求体**
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 卡片标题 |
| content | string | 是 | 卡片内容 |
| category | string | 是 | 分类（人生阅历/家庭菜谱/成长故事/相处感悟） |

**示例**
```json
{
  "title": "爷爷的红烧肉",
  "content": "爷爷做的红烧肉秘诀：先炸后炖，冰糖上色，小火慢炖1小时...",
  "category": "家庭菜谱"
}
```

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": "card_001",
    "title": "爷爷的红烧肉",
    "content": "爷爷做的红烧肉秘诀：先炸后炖，冰糖上色...",
    "category": "家庭菜谱",
    "created_at": "2026-07-24T10:00:00Z"
  }
}
```

#### 3.3.4 更新卡片

**请求**
```
PUT /memory/cards/{card_id}
```

**路径参数**
| 参数 | 类型 | 说明 |
|------|------|------|
| card_id | string | 卡片ID |

**请求体**
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 否 | 卡片标题 |
| content | string | 否 | 卡片内容 |
| category | string | 否 | 分类 |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": "card_001",
    "title": "爷爷的红烧肉（更新版）",
    "content": "更新后的内容...",
    "category": "家庭菜谱",
    "created_at": "2026-07-24T10:00:00Z",
    "updated_at": "2026-07-24T11:00:00Z"
  }
}
```

#### 3.3.5 删除卡片

**请求**
```
DELETE /memory/cards/{card_id}
```

**路径参数**
| 参数 | 类型 | 说明 |
|------|------|------|
| card_id | string | 卡片ID |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "已删除",
  "data": {}
}
```

---

### 3.4 用户档案接口 (Profile)

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 获取用户信息 | GET | `/profile` | 获取当前用户信息 |
| 更新用户信息 | PUT | `/profile` | 更新用户信息 |

#### 3.4.1 获取用户信息

**请求**
```
GET /profile
```

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "id": "user_001",
    "nickname": "小明",
    "avatar": null,
    "family_id": "family_001",
    "created_at": "2026-07-24T10:00:00Z"
  }
}
```

#### 3.4.2 更新用户信息

**请求**
```
PUT /profile
```

**请求体**
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | 否 | 用户昵称 |
| avatar | string | 否 | 头像URL |

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": "user_001",
    "nickname": "新昵称",
    "avatar": null,
    "family_id": "family_001",
    "created_at": "2026-07-24T10:00:00Z"
  }
}
```

---

### 3.5 家庭组接口 (Family)

| 接口 | 方法 | 路径 | 描述 |
|------|------|------|------|
| 获取我的家庭组 | GET | `/family/my-group` | 获取当前用户所在家庭组 |

#### 3.5.1 获取我的家庭组

**请求**
```
GET /family/my-group
```

**响应**
```json
{
  "success": true,
  "code": 200,
  "message": "success",
  "data": {
    "family_id": "family_001"
  }
}
```

---

## 四、数据类型定义

### 4.1 ChatMessage

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 消息ID |
| role | 'user' \| 'assistant' \| 'system' | 角色 |
| content | string | 消息内容 |
| created_at | string | 创建时间 |

### 4.2 Conversation

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 对话ID |
| title | string | 对话标题 |
| created_at | string | 创建时间 |
| updated_at | string | 更新时间 |

### 4.3 NVCPrompt

| 字段 | 类型 | 说明 |
|------|------|------|
| observation | string | 观察 |
| feeling | string | 感受 |
| need | string | 需要 |
| request | string | 请求 |

### 4.4 MemoryCard

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 卡片ID |
| title | string | 标题 |
| content | string | 内容 |
| category | string | 分类 |
| created_at | string | 创建时间 |
| updated_at | string | 更新时间 |

### 4.5 UserProfile

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 用户ID |
| nickname | string | 昵称 |
| avatar | string | 头像URL |
| family_id | string | 家庭组ID |
| created_at | string | 创建时间 |

---

## 五、本地开发配置

### 5.1 启动后端服务

```bash
# 克隆后端仓库
git clone <backend-repo-url>
cd backend

# 安装依赖
pip install -r requirements.txt

# 启动服务
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 5.2 跨域配置

后端需配置 CORS 以支持鸿蒙应用访问：

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 5.3 前端配置

在 `http.ts` 中修改基础URL：

```typescript
const BASE_URL = 'http://localhost:8000/api/v1';
```

---

## 六、调试技巧

### 6.1 查看请求日志

HTTP服务会输出详细的请求日志：

```
[HTTP][1] Request: POST /chat
[HTTP][1] Success: 200
```

### 6.2 错误处理

前端应捕获 `HttpError` 并根据错误类型处理：

```typescript
try {
  const response = await ChatAPI.sendMessage('hello');
} catch (error) {
  const err = error as HttpError;
  if (err.isTimeout) {
    showToast('请求超时，请重试');
  } else if (err.isNetworkError) {
    showToast('网络连接失败');
  }
}
```

---

**文档版本**: v1.0  
**生成日期**: 2026年7月24日  
**团队**: neko hackers