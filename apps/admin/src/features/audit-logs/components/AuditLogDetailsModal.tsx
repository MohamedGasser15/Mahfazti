import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X,
  Shield,
  Clock,
  Calendar,
  Globe,
  Tag,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  Copy,
  Check,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import type { AuditLogEntry } from '../types';
import {
  formatAuditAction,
  formatAuditCategory,
  formatAuditStatus,
  formatAdminName,
  formatAuditDetails,
} from '../utils/auditLocalization';

interface AuditLogDetailsModalProps {
  log: AuditLogEntry | null;
  isOpen: boolean;
  onClose: () => void;
}

export const AuditLogDetailsModal: React.FC<AuditLogDetailsModalProps> = ({
  log,
  isOpen,
  onClose,
}) => {
  const { t, isAr } = useLocale();
  const [copied, setCopied] = useState(false);

  if (!isOpen || !log) return null;

  const handleCopyDetails = () => {
    const text = JSON.stringify(log, null, 2);
    navigator.clipboard.writeText(text);
    setCopied(true);
    toast.success(t.auditLogs.modal.copiedToast);
    setTimeout(() => setCopied(false), 2000);
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'Success':
        return <CheckCircle2 className="h-4 w-4 text-emerald-500" />;
      case 'Warning':
        return <AlertTriangle className="h-4 w-4 text-amber-500" />;
      default:
        return <XCircle className="h-4 w-4 text-rose-500" />;
    }
  };

  const getStatusVariant = (status: string) => {
    switch (status) {
      case 'Success':
        return 'success';
      case 'Warning':
        return 'warning';
      default:
        return 'danger';
    }
  };

  const getCategoryBadgeVariant = (cat: string) => {
    switch (cat) {
      case 'Security':
        return 'purple';
      case 'User Management':
        return 'info';
      case 'Billing & Pricing':
        return 'warning';
      default:
        return 'default';
    }
  };

  return (
    <AnimatePresence>
      <motion.div
        key="audit-details-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.18 }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md"
      >
        <motion.div
          key="audit-details-modal"
          initial={{ opacity: 0, scale: 0.96, y: 10 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.96, y: 8 }}
          transition={{ duration: 0.22, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-lg rounded-3xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white"
        >
          {/* Header Ambient Glow */}
          <div className="absolute top-0 inset-x-0 h-24 bg-gradient-to-b from-blue-500/10 via-blue-500/5 to-transparent pointer-events-none" />

          {/* Close button */}
          <button
            type="button"
            onClick={onClose}
            className="absolute top-4 end-4 z-10 rounded-full p-2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/60 transition-colors"
          >
            <X className="h-4 w-4" />
          </button>

          <div className="p-6 space-y-5">
            {/* Header: Icon, Action, Status */}
            <div className="flex items-start gap-3.5 pe-8">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-blue-500/10 dark:bg-blue-500/20 text-blue-600 dark:text-blue-400 ring-4 ring-blue-500/5">
                <Shield className="h-6 w-6" />
              </div>
              <div className="space-y-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <h3 className="text-base font-bold text-zinc-950 dark:text-white leading-snug break-words">
                    {formatAuditAction(log.action, isAr)}
                  </h3>
                  <Badge variant={getStatusVariant(log.status)} className="text-[10px] py-0 px-2 font-bold gap-1">
                    {getStatusIcon(log.status)}
                    <span>{formatAuditStatus(log.status, isAr)}</span>
                  </Badge>
                </div>
                <p className="text-xs text-zinc-500 dark:text-zinc-400 font-mono break-all">
                  {log.targetResource}
                </p>
              </div>
            </div>

            {/* Admin Profile Box */}
            <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-200/80 dark:border-zinc-800/80 space-y-2">
              <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">
                {t.auditLogs.modal.executedBy}
              </span>
              <div className="flex items-center gap-3">
                <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-zinc-950 dark:bg-zinc-800 text-white font-black text-xs shadow-2xs">
                  {log.adminName.trim().charAt(0).toUpperCase() || 'A'}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-bold text-zinc-900 dark:text-white truncate">
                    {formatAdminName(log.adminName, isAr)}
                  </p>
                  <p className="text-[11px] text-zinc-500 dark:text-zinc-400 font-mono truncate">
                    {log.adminEmail}
                  </p>
                </div>
              </div>
            </div>

            {/* Details Grid */}
            <div className="grid grid-cols-2 gap-2.5 text-xs">
              <div className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900/40 border border-zinc-200/60 dark:border-zinc-800/60 space-y-1">
                <span className="text-[10px] text-zinc-400 dark:text-zinc-500 font-bold uppercase tracking-wider flex items-center gap-1">
                  <Tag className="h-3 w-3" />
                  {t.auditLogs.modal.category}
                </span>
                <div>
                  <Badge variant={getCategoryBadgeVariant(log.category)} className="text-[10px] font-semibold">
                    {formatAuditCategory(log.category, isAr)}
                  </Badge>
                </div>
              </div>

              <div className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900/40 border border-zinc-200/60 dark:border-zinc-800/60 space-y-1">
                <span className="text-[10px] text-zinc-400 dark:text-zinc-500 font-bold uppercase tracking-wider flex items-center gap-1">
                  <Globe className="h-3 w-3" />
                  {t.auditLogs.modal.ipAddress}
                </span>
                <p className="font-mono font-semibold text-zinc-800 dark:text-zinc-200">
                  {log.ipAddress || '127.0.0.1'}
                </p>
              </div>

              <div className="col-span-2 p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900/40 border border-zinc-200/60 dark:border-zinc-800/60 flex items-center justify-between text-[11px] text-zinc-500 dark:text-zinc-400">
                <span className="flex items-center gap-1.5">
                  <Calendar className="h-3.5 w-3.5 text-blue-500" />
                  <span>{formatDate(log.createdAt, isAr ? 'ar-EG' : 'en-US')}</span>
                </span>
                <span className="flex items-center gap-1.5 font-mono">
                  <Clock className="h-3.5 w-3.5 text-zinc-400" />
                  <span>
                    {new Date(log.createdAt).toLocaleTimeString(isAr ? 'ar-EG' : 'en-US', {
                      hour: '2-digit',
                      minute: '2-digit',
                      second: '2-digit',
                    })}
                  </span>
                </span>
              </div>
            </div>

            {/* Extra Technical Details / Payload if available */}
            {log.details && (
              <div className="space-y-1.5 text-start">
                <span className="text-[11px] font-bold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                  {t.auditLogs.modal.notesTitle}
                </span>
                <div className="p-3 rounded-xl bg-zinc-900 dark:bg-black/60 border border-zinc-800 text-[11px] font-mono text-zinc-300 overflow-x-auto max-h-32">
                  {formatAuditDetails(log.details, isAr)}
                </div>
              </div>
            )}
          </div>

          {/* Footer Actions */}
          <div className="p-4 border-t border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/40 flex items-center justify-between">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleCopyDetails}
              className="text-xs font-semibold gap-1.5"
            >
              {copied ? <Check className="h-3.5 w-3.5 text-emerald-500" /> : <Copy className="h-3.5 w-3.5" />}
              <span>{t.auditLogs.modal.copyRecord}</span>
            </Button>

            <Button
              type="button"
              variant="primary"
              size="sm"
              onClick={onClose}
              className="font-bold text-xs px-4"
            >
              {t.auditLogs.modal.closeBtn}
            </Button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
