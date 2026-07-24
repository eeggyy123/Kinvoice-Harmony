import { httpService } from './http';

export interface ChatMessage {
  id?: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  created_at?: string;
}

export interface Conversation {
  id: number;
  title: string;
  created_at: string;
  updated_at?: string;
}

export interface ChatResponse {
  reply: string;
  conversation_id?: number;
  messages?: ChatMessage[];
}

export interface NVCPrompt {
  observation: string;
  feeling: string;
  need: string;
  request: string;
}

export interface NVCSuggestion {
  nvc_expression: string;
  prompt: NVCPrompt;
}

export interface MemoryCard {
  id: string;
  title: string;
  content: string;
  category: string;
  created_at: string;
  updated_at?: string;
}

export interface UserProfile {
  id: string;
  nickname: string;
  avatar?: string;
  family_id?: string;
  created_at: string;
}

export interface APIResponse<T> {
  success: boolean;
  code: number;
  message: string;
  data: T;
}

export class ChatAPI {
  static async sendMessage(message: string, conversationId?: number, familyId?: string): Promise<APIResponse<ChatResponse>> {
    const response = await httpService.post<APIResponse<ChatResponse>>('/chat', {
      message,
      conversation_id: conversationId || null,
      family_id: familyId || null
    });
    return response.data;
  }

  static async getHistory(conversationId: number): Promise<APIResponse<{ messages: ChatMessage[] }>> {
    const response = await httpService.get<APIResponse<{ messages: ChatMessage[] }>>(`/chat/history/${conversationId}`);
    return response.data;
  }

  static async listConversations(): Promise<APIResponse<{ conversations: Conversation[] }>> {
    const response = await httpService.get<APIResponse<{ conversations: Conversation[] }>>('/chat/conversations');
    return response.data;
  }

  static async deleteConversation(conversationId: number): Promise<APIResponse<Object>> {
    const response = await httpService.delete<APIResponse<Object>>(`/chat/conversations/${conversationId}`);
    return response.data;
  }
}

export class NVCAPI {
  static async convert(text: string): Promise<APIResponse<NVCSuggestion>> {
    const response = await httpService.post<APIResponse<NVCSuggestion>>('/nvc/convert', { text });
    return response.data;
  }
}

export class MemoryAPI {
  static async listCards(): Promise<APIResponse<{ cards: MemoryCard[] }>> {
    const response = await httpService.get<APIResponse<{ cards: MemoryCard[] }>>('/memory/cards');
    return response.data;
  }

  static async getCard(id: string): Promise<APIResponse<MemoryCard>> {
    const response = await httpService.get<APIResponse<MemoryCard>>(`/memory/cards/${id}`);
    return response.data;
  }

  static async createCard(data: Partial<MemoryCard>): Promise<APIResponse<MemoryCard>> {
    const response = await httpService.post<APIResponse<MemoryCard>>('/memory/cards', data);
    return response.data;
  }

  static async updateCard(id: string, data: Partial<MemoryCard>): Promise<APIResponse<MemoryCard>> {
    const response = await httpService.put<APIResponse<MemoryCard>>(`/memory/cards/${id}`, data);
    return response.data;
  }

  static async deleteCard(id: string): Promise<APIResponse<Object>> {
    const response = await httpService.delete<APIResponse<Object>>(`/memory/cards/${id}`);
    return response.data;
  }
}

export interface AuthRequest {
  username: string;
  password: string;
  nickname?: string;
}

export interface AuthResponse {
  user: UserProfile;
  token?: string;
}

export class ProfileAPI {
  static async login(data: AuthRequest): Promise<APIResponse<AuthResponse>> {
    const response = await httpService.post<APIResponse<AuthResponse>>('/auth/login', data);
    return response.data;
  }

  static async register(data: AuthRequest): Promise<APIResponse<AuthResponse>> {
    const response = await httpService.post<APIResponse<AuthResponse>>('/auth/register', data);
    return response.data;
  }

  static async getProfile(): Promise<APIResponse<UserProfile>> {
    const response = await httpService.get<APIResponse<UserProfile>>('/profile');
    return response.data;
  }

  static async updateProfile(data: Partial<UserProfile>): Promise<APIResponse<UserProfile>> {
    const response = await httpService.put<APIResponse<UserProfile>>('/profile', data);
    return response.data;
  }
}

export class FamilyAPI {
  static async getMyGroup(): Promise<APIResponse<{ family_id: string }>> {
    const response = await httpService.get<APIResponse<{ family_id: string }>>('/family/my-group');
    return response.data;
  }
}
