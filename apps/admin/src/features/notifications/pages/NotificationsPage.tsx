import React, { useState } from 'react';
import { Send, Bell, Users, CheckCircle2, Sparkles, Smartphone } from 'lucide-react';
import { useNotifications } from '../hooks/useNotifications';
import { Card } from '../../../core/components/ui/Card';
import { Button } from '../../../core/components/ui/Button';
import { Badge } from '../../../core/components/ui/Badge';
import { formatDate } from '../../../core/utils/formatters';
import type { NotificationBroadcast } from '../types';

export const NotificationsPage: React.FC = () => {
  const { broadcasts, sendBroadcast, isLoading } = useNotifications();
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [audience, setAudience] = useState<NotificationBroadcast['targetAudience']>('All Users');
  const [isSending, setIsSending] = useState(false);
  const [sentSuccess, setSentSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !message) return;
    setIsSending(true);
    await sendBroadcast(title, message, audience);
    setIsSending(false);
    setTitle('');
    setMessage('');
    setSentSuccess(true);
    setTimeout(() => setSentSuccess(false), 3000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
          Push Notifications & Broadcasts
        </h1>
        <p className="text-sm text-zinc-500 dark:text-zinc-400">
          Send announcements, promotional offers, and reminders directly to users' phones.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Notification Composer Form */}
        <Card className="lg:col-span-1 p-6 space-y-4 h-fit">
          <div className="flex items-center gap-2.5 border-b border-zinc-100 dark:border-zinc-800 pb-3">
            <Send className="h-4.5 w-4.5 text-blue-600 dark:text-blue-400" />
            <h2 className="text-sm font-bold text-zinc-900 dark:text-white">
              Compose Push Broadcast
            </h2>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 mb-1">
                Target Audience
              </label>
              <select
                value={audience}
                onChange={(e: any) => setAudience(e.target.value)}
                className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3 py-2 text-xs font-semibold text-black dark:text-white focus:outline-none"
              >
                <option value="All Users">All Users (جميع المستخدمين - 1,420)</option>
                <option value="Free Users">Free Users Only (المستخدمين المجانيين فقط - 1,072)</option>
                <option value="Pro Subscribers">Pro Subscribers (مشتركي Pro فقط - 348)</option>
                <option value="Inactive Users">Inactive Users (المستخدمين الخاملين)</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 mb-1">
                Notification Title
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. عرض نهاية الأسبوع على باقة Pro 🚀"
                className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3 py-2 text-xs text-black dark:text-white placeholder-zinc-400 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 mb-1">
                Message Body
              </label>
              <textarea
                rows={3}
                required
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="e.g. احصل على خصم 50% الآن وسجل مصاريفك بصوتك بلا حدود..."
                className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3 py-2 text-xs text-black dark:text-white placeholder-zinc-400 focus:outline-none"
              />
            </div>

            {/* Live Mobile Notification Preview */}
            <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-zinc-100 dark:bg-zinc-900/80 p-3.5 space-y-1.5">
              <div className="flex items-center gap-1.5 text-[10px] font-bold text-zinc-400 uppercase tracking-wider">
                <Smartphone className="h-3 w-3" />
                <span>Mobile Lockscreen Preview</span>
              </div>
              <div className="rounded-xl bg-white dark:bg-black border border-zinc-200/80 dark:border-zinc-800 p-2.5 shadow-xs">
                <div className="flex items-center gap-1.5 text-[10px] font-bold text-blue-600 dark:text-blue-400 mb-0.5">
                  <Bell className="h-3 w-3" />
                  <span>Mahfazti &bull; now</span>
                </div>
                <p className="text-xs font-bold text-zinc-900 dark:text-white truncate">
                  {title || 'عنوان الإشعار يظهر هنا'}
                </p>
                <p className="text-[11px] text-zinc-500 dark:text-zinc-400 line-clamp-2">
                  {message || 'نص الرسالة الترويجية أو التذكيرية للمستخدمين...'}
                </p>
              </div>
            </div>

            {sentSuccess && (
              <div className="flex items-center gap-1.5 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                <CheckCircle2 className="h-4 w-4" />
                <span>Broadcast sent to all devices!</span>
              </div>
            )}

            <Button type="submit" isLoading={isSending} className="w-full">
              <Send className="h-4 w-4" />
              <span>Send Broadcast Now</span>
            </Button>
          </form>
        </Card>

        {/* Broadcast History */}
        <div className="lg:col-span-2 space-y-4">
          <Card className="p-0 overflow-hidden">
            <div className="p-4 border-b border-zinc-100 dark:border-zinc-800">
              <h2 className="text-sm font-bold text-zinc-900 dark:text-white">
                Recent Broadcasts & Engagement
              </h2>
            </div>

            {isLoading ? (
              <div className="p-8 text-center text-zinc-400 text-xs">Loading broadcasts...</div>
            ) : (
              <div className="divide-y divide-zinc-100 dark:divide-zinc-800/60">
                {broadcasts.map((b) => (
                  <div key={b.id} className="p-4 hover:bg-zinc-50 dark:hover:bg-zinc-900/30 transition space-y-2">
                    <div className="flex items-start justify-between">
                      <div>
                        <h3 className="text-xs font-bold text-zinc-900 dark:text-white">
                          {b.title}
                        </h3>
                        <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                          {b.message}
                        </p>
                      </div>
                      <Badge variant="success">Sent</Badge>
                    </div>

                    <div className="flex flex-wrap items-center gap-4 text-[11px] text-zinc-400 pt-1">
                      <span className="flex items-center gap-1 text-zinc-600 dark:text-zinc-300 font-semibold">
                        <Users className="h-3.5 w-3.5 text-blue-500" />
                        {b.targetAudience} ({b.deliveredCount} devices)
                      </span>
                      <span className="flex items-center gap-1 font-semibold text-emerald-600 dark:text-emerald-400">
                        <Sparkles className="h-3.5 w-3.5" />
                        {b.openRatePercentage}% Open Rate
                      </span>
                      <span>{formatDate(b.sentAt)}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </div>
      </div>
    </div>
  );
};
