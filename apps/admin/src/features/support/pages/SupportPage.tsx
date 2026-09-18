import React from 'react';
import { AlertCircle, CheckCircle2, Clock } from 'lucide-react';
import { useSupport } from '../hooks/useSupport';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';

export const SupportPage: React.FC = () => {
  const { tickets, statusFilter, setStatusFilter, updateStatus, isLoading } = useSupport();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            Support Tickets & Feedback
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Handle user queries, billing complaints, and mobile app feature suggestions.
          </p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2 border-b border-zinc-100 dark:border-zinc-800 pb-2">
        {(['all', 'Open', 'In Progress', 'Resolved'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setStatusFilter(tab)}
            className={`rounded-xl px-4 py-2 text-xs font-semibold transition cursor-pointer ${
              statusFilter === tab
                ? 'bg-zinc-900 text-white dark:bg-white dark:text-black shadow-xs'
                : 'text-zinc-500 hover:text-black dark:text-zinc-400 dark:hover:text-white'
            }`}
          >
            {tab === 'all' ? 'All Tickets' : tab}
          </button>
        ))}
      </div>

      {/* Ticket Cards */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs">Loading support tickets...</div>
      ) : (
        <div className="space-y-4">
          {tickets.map((ticket) => (
            <Card key={ticket.id} className="p-6 space-y-4">
              <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="font-mono text-xs font-bold text-blue-600 dark:text-blue-400">
                      {ticket.ticketNumber}
                    </span>
                    <span className="text-zinc-300 dark:text-zinc-700">&bull;</span>
                    <span className="text-xs font-semibold text-zinc-500">{ticket.category}</span>
                    <span className="text-zinc-300 dark:text-zinc-700">&bull;</span>
                    <span className="text-xs text-zinc-400">{formatDate(ticket.createdAt)}</span>
                  </div>
                  <h3 className="text-sm font-bold text-zinc-900 dark:text-white">
                    {ticket.subject}
                  </h3>
                </div>

                <div className="flex items-center gap-2">
                  <Badge variant={ticket.priority === 'High' ? 'danger' : 'warning'}>
                    {ticket.priority === 'High' && <AlertCircle className="h-3 w-3" />}
                    {ticket.priority} Priority
                  </Badge>
                  <Badge variant={ticket.status === 'Resolved' ? 'success' : 'default'}>
                    {ticket.status}
                  </Badge>
                </div>
              </div>

              <div className="rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 p-4 border border-zinc-100 dark:border-zinc-800 text-xs text-zinc-700 dark:text-zinc-300 leading-relaxed font-arabic">
                "{ticket.message}"
              </div>

              <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between pt-2 border-t border-zinc-100 dark:border-zinc-800 text-xs">
                <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400">
                  <span className="font-bold text-zinc-900 dark:text-white">{ticket.userName}</span>
                  <span>({ticket.userEmail})</span>
                </div>

                <div className="flex items-center gap-2">
                  {ticket.status !== 'Resolved' && (
                    <Button
                      size="sm"
                      variant="primary"
                      onClick={() => updateStatus(ticket.id, 'Resolved')}
                    >
                      <CheckCircle2 className="h-3.5 w-3.5" />
                      <span>Mark Resolved</span>
                    </Button>
                  )}
                  {ticket.status === 'Open' && (
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => updateStatus(ticket.id, 'In Progress')}
                    >
                      <Clock className="h-3.5 w-3.5" />
                      <span>Start Handling</span>
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
