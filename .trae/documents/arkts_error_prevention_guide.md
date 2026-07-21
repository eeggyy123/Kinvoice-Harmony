# ArkTS 编译错误预防指南

## 一、类型系统约束

### 1. 禁止使用 `any` 和 `unknown` 类型

**错误代码**：
```typescript
export interface APIResponse<T = any> { }  // ❌ 禁止使用 any
const data = response.data as unknown;       // ❌ 禁止使用 unknown
```

**正确代码**：
```typescript
export interface APIResponse<T> { }          // ✅ 使用泛型约束
const data = response.data;                  // ✅ 直接使用，让编译器推断类型
```

**影响文件**：
- `services/api.ts`：`APIResponse<T = any>` → `APIResponse<T>`
- `services/http.ts`：所有 `as unknown as ...` 类型转换

### 2. 禁止使用 `Record<string, Object>` 类型转换

**错误代码**：
```typescript
const headers = response.header as Record<string, string>;  // ❌
```

**正确代码**：
```typescript
const headers = response.header as Object;  // ✅ 使用 Object 代替
```

### 3. 禁止使用 `Function` 类型

**错误代码**：
```typescript
private httpClient: { request: Function; destroy: Function };  // ❌
```

**正确代码**：
```typescript
interface HttpClient {
  request(url: string, options: Object): Promise<Object>;
  destroy(): void;
}
private httpClient: HttpClient;  // ✅ 使用显式接口
```

## 二、组件语法约束

### 1. 组件必须使用 `export default` 导出

**错误代码**：
```typescript
@Component
struct BreakIceTab { }  // ❌ 没有导出
```

**正确代码**：
```typescript
@Component
struct BreakIceTab { }
export default BreakIceTab;  // ✅ 必须添加 export default
```

### 2. 导入组件必须使用默认导入

**错误代码**：
```typescript
import { BreakIceTab } from '../components/BreakIceTab';  // ❌
```

**正确代码**：
```typescript
import BreakIceTab from '../components/BreakIceTab';  // ✅
```

### 3. 组件调用语法

**错误代码**：
```typescript
BreakIceTab();  // ❌ 函数式调用
BreakIceTab() {}  // ❌ 尾随 lambda
```

**正确代码**：
```typescript
BreakIceTab()  // ✅ 标签式调用
```

### 4. 尾随 lambda 只适用于 `@BuilderParam`

**错误**：组件使用尾随 lambda `{}` 但没有 `@BuilderParam` 属性

**正确**：只有包含 `@BuilderParam` 属性的组件才能使用尾随 lambda

## 三、API 模块导入约束

### 1. `@ohos.ability` 模块不存在

**错误代码**：
```typescript
import { UIAbilityContext } from '@ohos.ability';  // ❌ 模块不存在
```

**正确代码**：
```typescript
import { common } from '@kit.AbilityKit';
type UIAbilityContext = common.UIAbilityContext;  // ✅
```

### 2. `http.Http` 类型不存在

**错误代码**：
```typescript
private httpClient: http.Http;  // ❌ Http 类型不存在
```

**正确代码**：
```typescript
interface HttpClient {
  request(url: string, options: Object): Promise<Object>;
  destroy(): void;
}
private httpClient: HttpClient = http.createHttp() as HttpClient;  // ✅
```

## 四、枚举参数约束

### 1. Row 的 alignItems 必须使用 VerticalAlign

**错误代码**：
```typescript
Row().alignItems(HorizontalAlign.Center)  // ❌ Row 是水平布局，alignItems 控制垂直对齐
```

**正确代码**：
```typescript
Row().alignItems(VerticalAlign.Center)  // ✅ Row 使用 VerticalAlign
```

### 2. Column 的 alignItems 必须使用 HorizontalAlign

**错误代码**：
```typescript
Column().alignItems(VerticalAlign.Center)  // ❌ Column 是垂直布局，alignItems 控制水平对齐
```

**正确代码**：
```typescript
Column().alignItems(HorizontalAlign.Center)  // ✅ Column 使用 HorizontalAlign
```

## 五、结构类型约束

### 1. 禁止结构化类型赋值

**错误代码**：
```typescript
this.result = response.data;  // ❌ response.data 是 API 返回的结构类型，不能直接赋值给本地接口类型
```

**正确代码**：
```typescript
const data = response.data;
this.result = {
  nvc_expression: data.nvc_expression,
  prompt: {
    observation: data.prompt.observation,
    feeling: data.prompt.feeling,
    need: data.prompt.need,
    request: data.prompt.request
  }
};  // ✅ 显式构造对象
```

### 2. 禁止对象字面量作为类型声明

**错误代码**：
```typescript
interface ContextMenuMsg {
  content: string;
}
const msg: ContextMenuMsg = { content: 'test' };  // ❌ 可能与其他接口类型不兼容
```

**正确代码**：
```typescript
// 使用索引代替对象引用
@State contextMenuIndex: number = -1;
// 在需要时通过索引访问
const msg = this.messages[this.contextMenuIndex];
```

## 六、构建验证流程

### 1. 清理缓存
```bash
hvigorw clean
```

### 2. 完整构建
```bash
hvigorw assembleHap
```

### 3. 检查错误类型

| 错误码 | 含义 | 解决方案 |
|--------|------|----------|
| 10605008 | 使用了 any/unknown | 移除 any/unknown，使用显式类型 |
| 10605030 | 结构类型不支持 | 显式构造对象，不要直接赋值 |
| 10505001 | 模块/成员不存在 | 检查导入路径和模块版本 |
| 10905204 | 组件语法错误 | 使用正确的组件调用语法 |
| 10905102 | 尾随 lambda 错误 | 移除尾随 lambda，或添加 @BuilderParam |

## 七、编码规范检查清单

### 开发前检查
- [ ] 确认 API 模块导入路径正确（使用 `@kit.AbilityKit` 代替 `@ohos.ability`）
- [ ] 定义所有接口类型，不使用 `any`/`unknown`
- [ ] 使用显式接口代替 `Record<string, Object>`

### 组件开发检查
- [ ] 组件使用 `export default` 导出
- [ ] 导入组件使用 `import X from` 语法
- [ ] 组件调用使用 `X()` 语法，不要用 `X() {}`
- [ ] Row 使用 `VerticalAlign`，Column 使用 `HorizontalAlign`

### API 调用检查
- [ ] API 响应数据需要显式构造对象
- [ ] 不要直接赋值 `response.data` 给本地接口类型
- [ ] 使用泛型 `APIResponse<T>` 代替 `APIResponse<T = any>`

### 构建前检查
- [ ] 运行 `grep -rn 'any\|unknown\|as Record\|as Object'` 检查违规
- [ ] 运行 `grep -rn 'export default'` 检查组件导出
- [ ] 运行 `grep -rn 'import {.*} from'` 检查组件导入方式

## 八、常见错误案例

### 案例1：API 响应类型转换
**问题**：`response.data as APIResponse<ChatResponse>` 使用了类型转换
**解决方案**：直接返回 `response.data`，利用泛型推断

### 案例2：httpClient 类型定义
**问题**：`private httpClient: http.Http` Http 类型不存在
**解决方案**：定义 `HttpClient` 接口，使用 `http.createHttp() as HttpClient`

### 案例3：组件导入语法
**问题**：`import { BreakIceTab } from '...'` 命名导入
**解决方案**：改为 `import BreakIceTab from '...'` 默认导入

### 案例4：Row/Column 对齐参数
**问题**：`Row().alignItems(HorizontalAlign.Center)` 参数错误
**解决方案**：改为 `Row().alignItems(VerticalAlign.Center)`

## 九、调试技巧

### 1. 编译错误定位
- 错误信息格式：`Error Message: xxx At File: xxx:xx:xx`
- 行号和列号精确指向问题位置
- 优先修复 `10605008`（any/unknown）类型错误

### 2. 依赖链分析
- 一个文件的错误可能导致引用它的所有文件报错
- 优先修复底层依赖文件（如 `api.ts`、`http.ts`）
- 修复后重新构建验证

### 3. 类型推断问题
- ArkTS 编译器对类型推断要求严格
- 当类型不匹配时，需要显式构造对象
- 避免使用类型断言绕过编译器检查

## 十、参考资料

- [HarmonyOS ArkTS 开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/development-intro-api-V5/)
- [HarmonyOS 构建工具使用指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/build-tool-overview-0000001773454022)
- [HarmonyOS 组件开发规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui-component-overview-0000001774034207)
