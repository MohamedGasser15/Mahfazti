export type TicketPriority = 'High' | 'Medium' | 'Low';
export type TicketStatus = 'Open' | 'In Progress' | 'Resolved';

export interface SupportTicket {
  id: string;
  ticketNumber: string;
  userName: string;
  userEmail: string;
  subject: string;
  category: 'Billing & Payment' | 'AI Voice Recognition' | 'Sync & Wallets' | 'Feature Request';
  priority: TicketPriority;
  status: TicketStatus;
  message: string;
  createdAt: string;
}
