using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Api.Services
{
    public class FirebaseNotificationService : IFirebaseNotificationService
    {
        private readonly IProfileService _profileService;
        private readonly ILogger<FirebaseNotificationService> _logger;
        private static bool _isInitialized = false;
        private static readonly object _lock = new object();

        public FirebaseNotificationService(
            IConfiguration configuration,
            IProfileService profileService,
            ILogger<FirebaseNotificationService> logger)
        {
            _profileService = profileService;
            _logger = logger;

            EnsureInitialized(configuration);
        }

        private void EnsureInitialized(IConfiguration configuration)
        {
            if (_isInitialized) return;

            lock (_lock)
            {
                if (_isInitialized) return;

                try
                {
                    if (FirebaseApp.DefaultInstance != null)
                    {
                        _isInitialized = true;
                        return;
                    }

                    var credentialPath = configuration["Firebase:CredentialFilePath"] ?? "firebase-adminsdk.json";
                    if (!Path.IsPathRooted(credentialPath))
                    {
                        // Check base directory, then current directory
                        var baseCandidate = Path.Combine(AppContext.BaseDirectory, credentialPath);
                        if (File.Exists(baseCandidate))
                        {
                            credentialPath = baseCandidate;
                        }
                    }

                    if (File.Exists(credentialPath))
                    {
                        FirebaseApp.Create(new AppOptions
                        {
                            Credential = GoogleCredential.FromFile(credentialPath),
                            ProjectId = configuration["Firebase:ProjectId"] ?? "mahfazti-b3c28"
                        });
                        _isInitialized = true;
                        _logger.LogInformation("Firebase Admin SDK successfully initialized from {Path}", credentialPath);
                    }
                    else
                    {
                        _logger.LogWarning("Firebase credential file not found at: {Path}", credentialPath);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to initialize Firebase Admin SDK");
                }
            }
        }

        public async Task<bool> SendPushNotificationAsync(
            string fcmToken,
            string title,
            string body,
            Dictionary<string, string>? data = null)
        {
            if (string.IsNullOrWhiteSpace(fcmToken)) return false;

            try
            {
                var message = new Message
                {
                    Token = fcmToken,
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Data = data ?? new Dictionary<string, string>(),
                    Apns = new ApnsConfig
                    {
                        Aps = new Aps
                        {
                            Sound = "default",
                            Badge = 1
                        }
                    },
                    Android = new AndroidConfig
                    {
                        Priority = Priority.High,
                        Notification = new AndroidNotification
                        {
                            Sound = "default",
                            ChannelId = "default"
                        }
                    }
                };

                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
                _logger.LogInformation("Push notification successfully sent: {MessageId}", response);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending push notification to token {Token}", fcmToken);
                return false;
            }
        }

        public async Task<bool> SendToUserAsync(
            string userId,
            string title,
            string body,
            Dictionary<string, string>? data = null)
        {
            var token = await _profileService.GetFcmTokenAsync(userId);
            if (string.IsNullOrWhiteSpace(token))
            {
                _logger.LogWarning("Cannot send push notification: No FCM token registered for user {UserId}", userId);
                return false;
            }

            return await SendPushNotificationAsync(token, title, body, data);
        }
    }
}
