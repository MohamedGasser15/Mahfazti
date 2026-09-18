import type { SupportTicket } from '../types';

let mockTickets: SupportTicket[] = [
  {
    id: 'tick-1',
    ticketNumber: 'TCK-1042',
    userName: 'Karim Adel',
    userEmail: 'karim@example.com',
    subject: 'خصم من فودافون كاش ولم تفعل باقة Pro',
    category: 'Billing & Payment',
    priority: 'High',
    status: 'Open',
    message: 'دفعت عبر فوري/فودافون كاش ووصلتني رسالة الخصم، لكن حسابي لم يتحول إلى باقة Pro السنوية.',
    createdAt: '2026-09-18T19:30:00Z',
  },
  {
    id: 'tick-2',
    ticketNumber: 'TCK-1041',
    userName: 'Heba Tarek',
    userEmail: 'heba@example.com',
    subject: 'الصوت لا يسجل فئة البنزين بدقة',
    category: 'AI Voice Recognition',
    priority: 'Medium',
    status: 'In Progress',
    message: 'عندما أقول "حطيت بنزين بـ 400 جنيه"، يتم تصنيفها كـ تسوق أحياناً وليس وقود.',
    createdAt: '2026-09-17T15:20:00Z',
  },
  {
    id: 'tick-3',
    ticketNumber: 'TCK-1040',
    userName: 'Mostafa Nabil',
    userEmail: 'mostafa@example.com',
    subject: 'اقتراح: ويدجت لشاشة القفل',
    category: 'Feature Request',
    priority: 'Low',
    status: 'Resolved',
    message: 'هل يمكن إضافة Lockscreen Widget في تحديث iOS القادم لتسجيل المصاريف بسرعة؟',
    createdAt: '2026-09-16T11:00:00Z',
  },
];

export const supportService = {
  getTickets: async (): Promise<SupportTicket[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockTickets]), 100));
  },
  updateStatus: async (ticketId: string, status: SupportTicket['status']): Promise<SupportTicket> => {
    const ticket = mockTickets.find((t) => t.id === ticketId);
    if (ticket) ticket.status = status;
    return new Promise((resolve) => setTimeout(() => resolve({ ...ticket! }), 100));
  },
};
