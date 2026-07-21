import { audio, media } from '@kit.MultimediaKit';
import { BusinessError } from '@ohos.base';

export class AudioService {
  private static instance: AudioService;
  private audioPlayer: audio.AudioPlayer | null = null;

  private constructor() {}

  public static getInstance(): AudioService {
    if (!AudioService.instance) {
      AudioService.instance = new AudioService();
    }
    return AudioService.instance;
  }

  async initPlayer(): Promise<void> {
    if (!this.audioPlayer) {
      this.audioPlayer = new audio.AudioPlayer();
      this.audioPlayer.on('dataLoad', () => {
        console.info('[Audio] Audio data loaded');
      });
      this.audioPlayer.on('playComplete', () => {
        console.info('[Audio] Playback completed');
      });
      this.audioPlayer.on('error', (err: BusinessError) => {
        console.error('[Audio] Player error:', err);
      });
    }
  }

  async playTextToSpeech(text: string, voiceName: string = 'default'): Promise<void> {
    try {
      await this.initPlayer();
      if (!this.audioPlayer) return;

      const audioData = await this.synthesizeSpeech(text, voiceName);
      await this.audioPlayer.start(audioData);
    } catch (error) {
      console.error('[Audio] playTextToSpeech failed:', error);
      throw error;
    }
  }

  async synthesizeSpeech(text: string, voiceName: string): Promise<media.AudioDataDescriptor> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        const sampleRate = 44100;
        const channels = 1;
        const sampleFormat = audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE;
        const bytesPerSample = 2;

        const audioData = {
          data: new ArrayBuffer(1024),
          sampleRate,
          channels,
          sampleFormat,
          bytesPerSample
        } as media.AudioDataDescriptor;

        resolve(audioData);
      }, 100);
    });
  }

  async stop(): Promise<void> {
    if (this.audioPlayer) {
      await this.audioPlayer.stop();
    }
  }

  async pause(): Promise<void> {
    if (this.audioPlayer) {
      await this.audioPlayer.pause();
    }
  }

  async resume(): Promise<void> {
    if (this.audioPlayer) {
      await this.audioPlayer.resume();
    }
  }

  setVolume(volume: number): void {
    if (this.audioPlayer) {
      this.audioPlayer.setVolume(volume);
    }
  }

  setSpatialEffect(enable: boolean): void {
    if (this.audioPlayer) {
      this.audioPlayer.setSpatialEffect(enable);
    }
  }
}

export const audioService = AudioService.getInstance();
