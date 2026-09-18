export interface NotificationBroadcast {
  id: string;
  title: string;
  message: string;
  targetAudience: 'All Users' | 'Free Users' | 'Pro Subscribers' | 'Inactive Users';
  sentAt: string;
  deliveredCount: number;
  openRatePercentage: number;
  status: 'Sent' | 'Scheduled' | 'Draft';
}
