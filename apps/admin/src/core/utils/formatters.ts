export const formatCurrency = (amount: number, currency: string = 'EGP', isAr: boolean = false): string => {
  if (isAr) {
    const formattedNum = new Intl.NumberFormat('ar-EG', {
      maximumFractionDigits: 2,
      minimumFractionDigits: amount % 1 === 0 ? 0 : 2,
    }).format(amount);
    return `${formattedNum} ج.م`;
  }

  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency === 'EGP' ? 'EGP' : currency,
    maximumFractionDigits: 2,
  })
    .format(amount)
    .replace('EGP', 'EGP ');
};

export const formatDate = (dateString: string, locale: string = 'en-US'): string => {
  const date = new Date(dateString);
  if (isNaN(date.getTime())) return dateString;
  return new Intl.DateTimeFormat(locale, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
};

export const formatTimeAgo = (dateString: string, isAr: boolean = false): string => {
  const date = new Date(dateString);
  const now = new Date();
  const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  if (diffInSeconds < 60) return isAr ? 'الآن' : 'Just now';
  if (diffInSeconds < 3600) {
    const mins = Math.floor(diffInSeconds / 60);
    return isAr ? `منذ ${mins} دقيقة` : `${mins} mins ago`;
  }
  if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600);
    return isAr ? `منذ ${hours} ساعة` : `${hours} hours ago`;
  }
  const days = Math.floor(diffInSeconds / 86400);
  return isAr ? `منذ ${days} يوم` : `${days} days ago`;
};

