import Foundation
import UserNotifications
import UIKit

@MainActor
final class DailyNotificationService:NSObject,UNUserNotificationCenterDelegate {
    static let shared=DailyNotificationService()
    static let openDaily=Notification.Name("MathTricks.openDailyPractice")
    private let identifier="math-tricks.daily-practice"
    private let center=UNUserNotificationCenter.current()
    private(set) var pendingOpen=false
    private override init(){super.init();center.delegate=self}
    func install(){center.delegate=self}
    func consumeOpen(){pendingOpen=false}
    func authorized() async -> Bool {
        let settings=await center.notificationSettings()
        return [.authorized,.provisional,.ephemeral].contains(settings.authorizationStatus)
    }
    func setEnabled(_ enabled:Bool,data:AppDataStore) async throws -> Bool {
        if !enabled {try await data.updateDailyOptions(.notifications(false));cancel();return false}
        let permission=try await center.requestAuthorization(options:[.alert,.sound])
        guard permission else {try await data.updateDailyOptions(.notifications(false));cancel();return false}
        try await data.updateDailyOptions(.notifications(true))
        try await schedule(data.snapshot)
        return true
    }
    func schedule(_ state:ProgressState?) async throws {
        guard let state,state.daily.notificationsEnabled==true,await authorized() else {cancel();return}
        let options=state.settings.dailyReminder ?? DailyReminderSettings()
        let content=UNMutableNotificationContent();content.title="Math Tricks";content.body=CatalogText.ui("daily_reminder_message");content.sound = .default
        content.userInfo=["route":"daily-practice"]
        let trigger=UNCalendarNotificationTrigger(dateMatching:DateComponents(hour:options.hour,minute:options.minute),repeats:true)
        try await center.add(UNNotificationRequest(identifier:identifier,content:content,trigger:trigger))
    }
    func cancel(){center.removePendingNotificationRequests(withIdentifiers:[identifier]);center.removeDeliveredNotifications(withIdentifiers:[identifier])}
    nonisolated func userNotificationCenter(_ center:UNUserNotificationCenter,didReceive response:UNNotificationResponse,withCompletionHandler completionHandler:@escaping ()->Void){
        guard response.notification.request.identifier=="math-tricks.daily-practice" else {completionHandler();return}
        Task{@MainActor in self.pendingOpen=true;NotificationCenter.default.post(name:Self.openDaily,object:nil);completionHandler()}
    }
    nonisolated func userNotificationCenter(_ center:UNUserNotificationCenter,willPresent notification:UNNotification,withCompletionHandler completionHandler:@escaping (UNNotificationPresentationOptions)->Void){completionHandler([.banner,.sound])}
}
