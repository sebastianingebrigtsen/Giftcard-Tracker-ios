import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    print("Notification permission error:", error)
                } else {
                    print("Notification permission granted:", granted)
                }
            }
        }
    }

    func scheduleNotifications(for card: GiftCard, daysBefore: [Int] = [7, 1]) {
        cancelNotifications(for: card)

        let center = UNUserNotificationCenter.current()

        for d in daysBefore {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -d, to: card.expiryDate),
                  fireDate > Date()
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Gavekort utløper snart"
            content.body = "\(card.storeName)-gavekortet ditt utløper om \(d) dag\(d == 1 ? "" : "er")."
            content.sound = .default

            var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            components.hour = 9
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let id = "\(card.uuid.uuidString)_\(d)d"

            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancelNotifications(for card: GiftCard, daysBefore: [Int] = [7, 1]) {
        let ids = daysBefore.map { "\(card.uuid.uuidString)_\($0)d" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // DEBUG – bruk for å verifisere at varsler faktisk legges inn
    func scheduleTestNotificationIn10Seconds() {
        let content = UNMutableNotificationContent()
        content.title = "Testvarsel"
        content.body = "Notifikasjoner fungerer ✅"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "test_10s", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
