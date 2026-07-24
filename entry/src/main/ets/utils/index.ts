import storage from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';
type UIAbilityContext = common.UIAbilityContext;

export const MorandiColors = {
  bg: '#e8e4df',
  bgDark: '#dcd5ce',
  green: '#b5c4b1',
  greenDark: '#9ab09a',
  pink: '#d4c5c0',
  blue: '#a3b5c7',
  blueDark: '#8a9eb2',
  brown: '#c4b7a6',
  text: '#5c5c5c',
  textLight: '#9a9490',
  white: '#faf8f5',
  border: '#d9d3cb'
};

export const Constants = {
  STORAGE_KEY_CONV_ID: 'companion_conv_id',
  STORAGE_KEY_CONV_LIST: 'companion_conv_list',
  STORAGE_KEY_CONV_MSG_PREFIX: 'conv_msgs_',
  STORAGE_KEY_SELECTED_VOICE: 'selected_voice',
  STORAGE_KEY_TOKEN: 'auth_token',
  STORAGE_KEY_USER_NICKNAME: 'user_nickname',
  DOUBLE_CLICK_DELAY: 500
};

let preferences: storage.Preferences | null = null;
let appContext: UIAbilityContext | null = null;

export function setAppContext(ctx: UIAbilityContext): void {
  appContext = ctx;
}

export function getAppContext(): UIAbilityContext {
  return appContext!;
}

export async function getPreferences(): Promise<storage.Preferences> {
  if (!preferences) {
    try {
      preferences = await storage.getPreferences(getAppContext(), 'kinvoice_prefs');
    } catch (error) {
      console.error('Failed to get preferences:', error);
      throw error;
    }
  }
  return preferences;
}

export async function setStorage(key: string, value: string | Object): Promise<void> {
  try {
    const prefs = await getPreferences();
    const strValue = typeof value === 'string' ? value : JSON.stringify(value);
    await prefs.put(key, strValue);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to set storage:', error);
    throw error;
  }
}

export async function getStorage(key: string, defaultValue?: string | Object): Promise<string | Object | null> {
  try {
    const prefs = await getPreferences();
    const value = await prefs.get(key, defaultValue);
    if (value && typeof value === 'string') {
      try {
        return JSON.parse(value);
      } catch {
        return value;
      }
    }
    return value ?? null;
  } catch (error) {
    console.error('Failed to get storage:', error);
    throw error;
  }
}

export async function removeStorage(key: string): Promise<void> {
  try {
    const prefs = await getPreferences();
    await prefs.delete(key);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to remove storage:', error);
    throw error;
  }
}

export function generateLocalId(): number {
  return Date.now();
}

export function formatDate(timestamp: number | string): string {
  let ts: number;
  if (typeof timestamp === 'string') {
    ts = new Date(timestamp).getTime();
  } else {
    ts = timestamp;
  }
  const d = new Date(ts);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

export interface MessageItem {
  role: string;
  content: string;
}

export function makeTitle(messages: MessageItem[]): string {
  const firstUser = messages.find(m => m.role === 'user');
  if (firstUser) {
    return firstUser.content.length > 20
      ? firstUser.content.substring(0, 20) + '...'
      : firstUser.content;
  }
  return '新对话';
}

export function debounce(fn: () => void, delay: number): () => void {
  let timer: ReturnType<typeof setTimeout> | null = null;
  return () => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => fn(), delay);
  };
}

export function throttle(fn: () => void, delay: number): () => void {
  let lastTime = 0;
  return () => {
    const now = Date.now();
    if (now - lastTime >= delay) {
      lastTime = now;
      fn();
    }
  };
}
