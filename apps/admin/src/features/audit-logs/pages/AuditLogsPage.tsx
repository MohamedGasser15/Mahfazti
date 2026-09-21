import React, { useState } from 'react';
import {
  Shield,
  RotateCcw,
  Search,
  X,
  Eye,
  Copy,
  Check,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  Layers,
  ChevronLeft,
  ChevronRight,
  Filter,
  LayoutList,
  LayoutGrid,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { useViewMode } from '../../../core/context/ViewModeContext';
import { useAuditLogs } from '../hooks/useAuditLogs';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import type { AuditLogEntry } from '../types';
import { AuditLogsSkeleton } from '../components/AuditLogsSkeleton';
import { AuditLogsTable } from '../components/AuditLogsTable';
import { AuditLogsKpiCards } from '../components/AuditLogsKpiCards';
import { AuditLogDetailsModal } from '../components/AuditLogDetailsModal';
import {
  formatAuditAction,
  formatAuditCategory,
  formatAuditStatus,
  formatAdminName,
} from '../utils/auditLocalization';

export const AuditLogsPage: React.FC = () => {
  const { isAr, t } = useLocale();
  const { viewMode, setViewMode } = useViewMode();

  const {
    logs,
    stats,
    categoryCounts,
    categoryFilter,
    setCategoryFilter,
    statusFilter,
    setStatusFilter,
    searchTerm,
    setSearchTerm,
    currentPage,
    totalPages,
    totalCount,
    pageSize,
    goToPage,
    nextPage,
    prevPage,
    isLoading,
    isRefreshing,
    refetch,
  } = useAuditLogs();

  const [selectedLog, setSelectedLog] = useState<AuditLogEntry | null>(null);
  const [copiedId, setCopiedId] = useState<string | number | null>(null);

  const handleCopy = (text: string, id: string | number) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    toast.success(t.auditLogs.table.copiedToast);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'Success':
        return <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />;
      case 'Warning':
        return <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />;
      default:
        return <XCircle className="h-3.5 w-3.5 text-rose-500" />;
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

  const startRecord = totalCount > 0 ? (currentPage - 1) * pageSize + 1 : 0;
  const endRecord = Math.min(currentPage * pageSize, totalCount);

  return (
    <div className="space-y-6 pb-12">
      {/* 1. Executive Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-950 shadow-md">
              <Shield className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {t.auditLogs.pageTitle}
              </h1>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                {t.auditLogs.pageSubtitle}
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={refetch}
            disabled={isLoading || isRefreshing}
            className="font-bold border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300"
          >
            <RotateCcw
              className={`h-4 w-4 me-1.5 ${isRefreshing || isLoading ? 'animate-spin' : ''}`}
            />
            <span>{t.auditLogs.refresh}</span>
          </Button>
        </div>
      </div>

      {/* 2. Top KPI Metrics Summary Cards */}
      <AuditLogsKpiCards
        stats={stats}
        isLoading={isLoading}
        hasLogs={totalCount > 0}
      />

      {/* 3. Filter Tabs & Search Bar */}
      <div className="space-y-3">
        {/* Status / Category Tabs Bar & View Mode Toggle */}
        <div className="flex items-center justify-between gap-2 overflow-x-auto pb-1">
          <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            {[
              { id: 'all', label: t.auditLogs.tabs.all, count: categoryCounts?.all ?? stats.totalLogs },
              {
                id: 'User Management',
                label: t.auditLogs.tabs.userManagement,
                count: categoryCounts?.['User Management'] ?? stats.userManagementCount,
              },
              {
                id: 'Security',
                label: t.auditLogs.tabs.security,
                count: categoryCounts?.['Security'] ?? stats.securityCount,
              },
              {
                id: 'Billing & Pricing',
                label: t.auditLogs.tabs.billingPricing,
                count: categoryCounts?.['Billing & Pricing'] ?? 0,
              },
              {
                id: 'System',
                label: t.auditLogs.tabs.system,
                count: categoryCounts?.['System'] ?? 0,
              },
            ].map((tab) => {
              const isActive = categoryFilter === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setCategoryFilter(tab.id)}
                  className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
                    isActive
                      ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                      : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white hover:bg-zinc-200/60 dark:hover:bg-zinc-800/60'
                  }`}
                >
                  <span>{tab.label}</span>
                  {tab.count !== null && (
                    <span
                      className={`px-1.5 py-0.2 rounded-full text-[10px] font-mono ${
                        isActive
                          ? 'bg-zinc-800 dark:bg-zinc-200 text-zinc-100 dark:text-zinc-900'
                          : 'bg-zinc-300/60 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400'
                      }`}
                    >
                      {tab.count}
                    </span>
                  )}
                </button>
              );
            })}
          </div>

          {/* View Mode Toggle (Table / Cards Grid) */}
          <div className="flex items-center gap-1 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800 shrink-0">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              title={t.auditLogs.filters.tableView}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
                viewMode === 'table'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutList className="h-4 w-4" />
            </button>
            <button
              type="button"
              onClick={() => setViewMode('cards')}
              title={t.auditLogs.filters.cardsView}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
                viewMode === 'cards'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Search & Status Filter Bar */}
        <Card className="flex flex-col sm:flex-row sm:items-center gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <div className="relative flex-1 w-full">
            <Search className="absolute top-1/2 start-3.5 -translate-y-1/2 h-4 w-4 text-zinc-400 dark:text-zinc-500" />
            <input
              type="text"
              placeholder={t.auditLogs.searchPlaceholder}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/80 py-2 ps-10 pe-9 text-xs font-semibold text-zinc-900 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors"
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm('')}
                className="absolute top-1/2 end-3 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 cursor-pointer"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto">
            <div className="relative min-w-[150px] w-full sm:w-auto">
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="w-full appearance-none rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/80 py-2 ps-3 pe-8 text-xs font-semibold text-zinc-800 dark:text-zinc-200 focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors cursor-pointer"
              >
                <option value="all">{t.auditLogs.allStatuses}</option>
                <option value="Success">{t.auditLogs.statuses.success}</option>
                <option value="Warning">{t.auditLogs.statuses.warning}</option>
                <option value="Failed">{t.auditLogs.statuses.failed}</option>
              </select>
              <Filter className="pointer-events-none absolute top-1/2 end-2.5 h-3.5 w-3.5 -translate-y-1/2 text-zinc-400" />
            </div>
          </div>
        </Card>
      </div>

      {/* 4. Content Area: Cards Grid or High-Craft Table */}
      {isLoading ? (
        <AuditLogsSkeleton count={pageSize} viewMode={viewMode} />
      ) : logs.length === 0 ? (
        <Card className="p-12 text-center bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 space-y-3">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-400">
            <Shield className="h-6 w-6" />
          </div>
          <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
            {t.auditLogs.emptyState.title}
          </h3>
          <p className="text-xs text-zinc-500 dark:text-zinc-400 max-w-sm mx-auto">
            {t.auditLogs.emptyState.description}
          </p>
          {(searchTerm || categoryFilter !== 'all' || statusFilter !== 'all') && (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setSearchTerm('');
                setCategoryFilter('all');
                setStatusFilter('all');
              }}
              className="mt-2 text-xs font-bold"
            >
              {t.auditLogs.emptyState.resetFilters}
            </Button>
          )}
        </Card>
      ) : viewMode === 'cards' ? (
        /* Cards Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {logs.map((entry) => (
            <Card
              key={entry.id}
              className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 flex flex-col justify-between space-y-4 shadow-2xs hover:border-zinc-300 dark:hover:border-zinc-700 transition"
            >
              {/* Top: Icon + Status & Category Badges */}
              <div className="flex items-start justify-between gap-3">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
                  <Layers className="h-5 w-5" />
                </div>
                <div className="flex flex-wrap items-center justify-end gap-1.5">
                  <Badge
                    variant={getCategoryBadgeVariant(entry.category)}
                    className="text-[10px] font-semibold"
                  >
                    {formatAuditCategory(entry.category, isAr)}
                  </Badge>
                  <Badge
                    variant={getStatusVariant(entry.status)}
                    className="text-[10px] font-bold gap-1"
                  >
                    {getStatusIcon(entry.status)}
                    <span>{formatAuditStatus(entry.status, isAr)}</span>
                  </Badge>
                </div>
              </div>

              {/* Action Title + Target Resource */}
              <div className="space-y-1.5 pt-1">
                <h4 className="font-bold text-sm text-zinc-950 dark:text-white leading-snug">
                  {formatAuditAction(entry.action, isAr)}
                </h4>
                <div className="flex items-center gap-1.5">
                  <span className="font-mono text-xs text-zinc-600 dark:text-zinc-400 truncate max-w-[200px]">
                    {entry.targetResource}
                  </span>
                  <button
                    type="button"
                    onClick={() => handleCopy(entry.targetResource, `res-${entry.id}`)}
                    title={t.auditLogs.table.copyResource}
                    className="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 transition-colors cursor-pointer"
                  >
                    {copiedId === `res-${entry.id}` ? (
                      <Check className="h-3 w-3 text-emerald-500" />
                    ) : (
                      <Copy className="h-3 w-3" />
                    )}
                  </button>
                </div>
              </div>

              {/* Admin & IP */}
              <div className="pt-2 border-t border-zinc-100 dark:border-zinc-800/80 space-y-0.5 text-xs">
                <div className="flex items-center justify-between text-zinc-900 dark:text-zinc-100 font-semibold">
                  <span className="truncate">{formatAdminName(entry.adminName, isAr)}</span>
                  <span className="font-mono text-[11px] text-zinc-500 dark:text-zinc-400 shrink-0">
                    {entry.ipAddress || '127.0.0.1'}
                  </span>
                </div>
                <p className="text-[11px] text-zinc-400 font-mono truncate">{entry.adminEmail}</p>
              </div>

              {/* Footer: Date & Details Modal Trigger */}
              <div className="pt-3 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                <span className="text-zinc-400 text-[11px]">
                  {formatDate(entry.createdAt, isAr ? 'ar-EG' : 'en-US')}
                </span>
                <Button
                  type="button"
                  size="sm"
                  variant="outline"
                  onClick={() => setSelectedLog(entry)}
                  className="h-7 px-2.5 text-xs font-bold gap-1 rounded-xl shadow-2xs"
                >
                  <Eye className="h-3.5 w-3.5" />
                  <span>{t.auditLogs.table.details}</span>
                </Button>
              </div>
            </Card>
          ))}
        </div>
      ) : (
        <AuditLogsTable
          logs={logs}
          isAr={isAr}
          copiedId={copiedId}
          onCopy={handleCopy}
          onSelectLog={setSelectedLog}
          t={t}
        />
      )}

      {/* 5. Pagination Toolbar */}
      {!isLoading && totalCount > 0 && (
        <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <p className="text-xs text-zinc-500 dark:text-zinc-400 text-center sm:text-start">
            {t.auditLogs.pagination.showing}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong>{' '}
            {t.auditLogs.pagination.to}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong>{' '}
            {t.auditLogs.pagination.of}{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{totalCount}</strong>{' '}
            {t.auditLogs.pagination.events}
          </p>

          <div className="flex items-center justify-center gap-1.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={prevPage}
              disabled={currentPage === 1}
              className="text-xs font-bold px-2.5"
            >
              {isAr ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
              <span className="ms-1">{t.auditLogs.pagination.prev}</span>
            </Button>

            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1)
                .filter((p) => p === 1 || p === totalPages || Math.abs(p - currentPage) <= 1)
                .map((p, idx, arr) => {
                  const prevP = arr[idx - 1];
                  const showEllipsis = prevP && p - prevP > 1;

                  return (
                    <React.Fragment key={p}>
                      {showEllipsis && <span className="px-1 text-zinc-400 font-mono">...</span>}
                      <button
                        type="button"
                        onClick={() => goToPage(p)}
                        className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
                          currentPage === p
                            ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                            : 'border border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                        }`}
                      >
                        {p}
                      </button>
                    </React.Fragment>
                  );
                })}
            </div>

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={nextPage}
              disabled={currentPage === totalPages}
              className="text-xs font-bold px-2.5"
            >
              <span className="me-1">{t.auditLogs.pagination.next}</span>
              {isAr ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </div>
        </Card>
      )}

      {/* 6. Details Inspection Modal */}
      <AuditLogDetailsModal
        log={selectedLog}
        isOpen={Boolean(selectedLog)}
        onClose={() => setSelectedLog(null)}
      />
    </div>
  );
};
