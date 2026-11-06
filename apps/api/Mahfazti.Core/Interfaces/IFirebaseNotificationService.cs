using System.Collections.Generic;
using System.Threading.Tasks;

namespace Mahfazti.Core.Interfaces
{
    public interface IFirebaseNotificationService
    {
        Task<bool> SendPushNotificationAsync(string fcmToken, string title, string body, Dictionary<string, string>? data = null);
        Task<bool> SendToUserAsync(string userId, string title, string body, Dictionary<string, string>? data = null);
    }
}
