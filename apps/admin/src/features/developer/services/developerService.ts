import type { WebhookEndpoint, WebhookLog, SystemHealthMetric } from '../types';

let mockEndpoints: WebhookEndpoint[] = [
  {
    id: 'wh-1',
    service: 'Paymob Gateway',
    url: 'https://api.mahfazti.app/v1/webhooks/paymob/processed',
    status: 'Active',
    lastDeliveryStatus: '200 OK',
    eventsCount: 1420,
    lastTriggeredAt: '2026-09-18T22:14:00Z',
  },
  {
    id: 'wh-2',
    service: 'Fawry Pay',
    url: 'https://api.mahfazti.app/v1/webhooks/fawry/status',
    status: 'Active',
    lastDeliveryStatus: '200 OK',
    eventsCount: 680,
    lastTriggeredAt: '2026-09-18T19:40:00Z',
  },
  {
    id: 'wh-3',
    service: 'Apple AppStore Server',
    url: 'https://api.mahfazti.app/v1/webhooks/apple/v2/notifications',
    status: 'Active',
    lastDeliveryStatus: '200 OK',
    eventsCount: 312,
    lastTriggeredAt: '2026-09-18T21:05:00Z',
  },
  {
    id: 'wh-4',
    service: 'Telegram Alert Bot',
    url: 'https://api.mahfazti.app/v1/webhooks/ops/telegram-alerts',
    status: 'Active',
    lastDeliveryStatus: '200 OK',
    eventsCount: 89,
    lastTriggeredAt: '2026-09-18T23:55:00Z',
  },
];

let mockWebhookLogs: WebhookLog[] = [
  {
    id: 'wl-101',
    event: 'TRANSACTION_SUCCESS',
    source: 'Paymob Gateway',
    statusCode: 200,
    payload: '{"order_id": 482910, "amount_cents": 8900, "currency": "EGP", "success": true}',
    durationMs: 42,
    timestamp: '2026-09-18T22:14:00Z',
  },
  {
    id: 'wl-102',
    event: 'SUBSCRIPTION_RENEWED',
    source: 'Apple AppStore Server',
    statusCode: 200,
    payload: '{"notification_type": "DID_RENEW", "sub_id": "com.mahfazti.pro.monthly"}',
    durationMs: 78,
    timestamp: '2026-09-18T21:05:00Z',
  },
  {
    id: 'wl-103',
    event: 'BILL_PAID',
    source: 'Fawry Pay',
    statusCode: 200,
    payload: '{"fawry_ref": "981240192", "status": "PAID", "amount": 699.00}',
    durationMs: 110,
    timestamp: '2026-09-18T19:40:00Z',
  },
];

let mockHealthMetrics: SystemHealthMetric[] = [
  {
    service: 'Egyptian Dialect AI Voice Engine',
    status: 'Healthy',
    latencyMs: 142,
    uptimePercent: 99.98,
    load: '18% CPU / Whisper-v3 Large',
    lastChecked: 'Just now',
  },
  {
    service: 'PostgreSQL Primary Cluster (Neon/RDS)',
    status: 'Healthy',
    latencyMs: 12,
    uptimePercent: 100.0,
    load: '24 / 100 connections',
    lastChecked: 'Just now',
  },
  {
    service: 'Redis Cache & Session Broker',
    status: 'Healthy',
    latencyMs: 2,
    uptimePercent: 99.99,
    load: '84.2% Cache Hit Ratio',
    lastChecked: 'Just now',
  },
  {
    service: 'FCM Push Notification Gateway',
    status: 'Healthy',
    latencyMs: 85,
    uptimePercent: 99.95,
    load: '0 pending in queue',
    lastChecked: '1m ago',
  },
  {
    service: 'Multi-Currency FX Exchange Feed',
    status: 'Healthy',
    latencyMs: 190,
    uptimePercent: 99.91,
    load: 'CBE Sync active',
    lastChecked: '15m ago',
  },
];

export const developerService = {
  getEndpoints: async (): Promise<WebhookEndpoint[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockEndpoints]), 100));
  },
  getWebhookLogs: async (): Promise<WebhookLog[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockWebhookLogs]), 100));
  },
  getHealthMetrics: async (): Promise<SystemHealthMetric[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockHealthMetrics]), 100));
  },
};
