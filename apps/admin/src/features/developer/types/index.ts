export interface WebhookEndpoint {
  id: string;
  service: 'Paymob Gateway' | 'Fawry Pay' | 'Apple AppStore Server' | 'Google Play Billing' | 'Telegram Alert Bot';
  url: string;
  status: 'Active' | 'Degraded' | 'Inactive';
  lastDeliveryStatus: '200 OK' | '500 Server Error' | '404 Not Found';
  eventsCount: number;
  lastTriggeredAt: string;
}

export interface WebhookLog {
  id: string;
  event: string;
  source: string;
  statusCode: number;
  payload: string;
  durationMs: number;
  timestamp: string;
}

export interface SystemHealthMetric {
  service: string;
  status: 'Healthy' | 'Warning' | 'Critical';
  latencyMs: number;
  uptimePercent: number;
  load: string;
  lastChecked: string;
}
