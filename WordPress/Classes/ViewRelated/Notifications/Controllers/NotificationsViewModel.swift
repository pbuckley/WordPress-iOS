final class NotificationsViewModel {
    enum Constants {
        static let lastSeenTime = "notifications_last_seen_time"
    }

    private let userDefaults: UserPersistentRepository
    private let notificationMediator: NotificationSyncMediatorProtocol?

    init(
        userDefaults: UserPersistentRepository,
        notificationMediator: NotificationSyncMediatorProtocol? = NotificationSyncMediator()
    ) {
        self.userDefaults = userDefaults
        self.notificationMediator = notificationMediator
    }

    /// The last time when user seen notifications
    var lastSeenTime: String? {
        get {
            return userDefaults.string(forKey: Constants.lastSeenTime)
        }
        set {
            userDefaults.set(newValue, forKey: Constants.lastSeenTime)
        }
    }

    func lastSeenChanged(timestamp: String?) {
        guard let timestamp,
              timestamp != lastSeenTime,
              let mediator = notificationMediator else {
            return
        }

        mediator.updateLastSeen(timestamp) { [weak self] error in
            guard error == nil else {
                return
            }

            self?.lastSeenTime = timestamp
        }
    }
}
