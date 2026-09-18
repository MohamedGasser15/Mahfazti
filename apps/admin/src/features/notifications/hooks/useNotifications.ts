import { useState, useEffect } from 'react';
import type { NotificationBroadcast } from '../types';
import { notificationsService } from '../services/notificationsService';

export const useNotifications = () => {
  const [broadcasts, setBroadcasts] = useState<NotificationBroadcast[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    notificationsService.getBroadcasts().then((res) => {
      setBroadcasts(res);
      setIsLoading(false);
    });
  }, []);

  const sendBroadcast = async (
    title: string,
    message: string,
    targetAudience: NotificationBroadcast['targetAudience']
  ) => {
    const created = await notificationsService.sendBroadcast({
      title,
      message,
      targetAudience,
    });
    setBroadcasts((prev) => [created, ...prev]);
  };

  return {
    broadcasts,
    sendBroadcast,
    isLoading,
  };
};
