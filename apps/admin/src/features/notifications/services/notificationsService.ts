import type { NotificationBroadcast } from '../types';

let mockBroadcasts: NotificationBroadcast[] = [
  {
    id: 'notif-1',
    title: 'خصم 50% على باقة Pro السنوية 🚀',
    message: 'استمتع بمحافظ غير محدودة وميزة تسجيل الصوت بالذكاء الاصطناعي بنصف السعر لفترة محدودة!',
    targetAudience: 'Free Users',
    sentAt: '2026-09-18T14:00:00Z',
    deliveredCount: 1072,
    openRatePercentage: 46.8,
    status: 'Sent',
  },
  {
    id: 'notif-2',
    title: 'تذكير: سجل مصاريفك اليومية 🎙️',
    message: 'وفر وقتك وسجل مصاريف اليوم بجملة صوتية واحدة فقط عبر محفظتي.',
    targetAudience: 'All Users',
    sentAt: '2026-09-17T20:30:00Z',
    deliveredCount: 1420,
    openRatePercentage: 38.2,
    status: 'Sent',
  },
];

export const notificationsService = {
  getBroadcasts: async (): Promise<NotificationBroadcast[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockBroadcasts]), 100));
  },
  sendBroadcast: async (broadcast: Omit<NotificationBroadcast, 'id' | 'sentAt' | 'deliveredCount' | 'openRatePercentage' | 'status'>): Promise<NotificationBroadcast> => {
    const newBroadcast: NotificationBroadcast = {
      ...broadcast,
      id: `notif-${Date.now()}`,
      sentAt: new Date().toISOString(),
      deliveredCount: 1420,
      openRatePercentage: 0,
      status: 'Sent',
    };
    mockBroadcasts.unshift(newBroadcast);
    return newBroadcast;
  },
};
