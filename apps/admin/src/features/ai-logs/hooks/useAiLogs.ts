import { useState, useEffect } from 'react';
import type { AiLogItem } from '../types';
import { aiLogsService } from '../services/aiLogsService';

export const useAiLogs = () => {
  const [logs, setLogs] = useState<AiLogItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    aiLogsService.getLogs().then((res) => {
      setLogs(res);
      setIsLoading(false);
    });
  }, []);

  return {
    logs,
    isLoading,
  };
};
