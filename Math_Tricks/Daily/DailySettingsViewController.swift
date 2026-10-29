import UIKit

final class DailySettingsViewController:ThemedViewController {
    private let enabled=UISwitch()
    private let time=UIDatePicker()
    private var goal:AppButton!
    private var difficulty:AppButton!
    private var status:AppLabel!
    private var busy=false
    override func buildContent(){
        view.accessibilityIdentifier="screen.dailySettings"
        let column=scrollStack()
        let row=UIStackView(arrangedSubviews:[label(MainText.text("enable_notifications")),enabled]);row.alignment = .center;column.addArrangedSubview(row)
        enabled.addTarget(self,action:#selector(enableChanged),for:.valueChanged)
        time.datePickerMode = .time;time.preferredDatePickerStyle = .wheels;time.addTarget(self,action:#selector(timeChanged),for:.valueChanged);column.addArrangedSubview(time)
        goal=button(""){[weak self] in self?.chooseGoal()};column.addArrangedSubview(goal)
        difficulty=button(""){[weak self] in self?.chooseDifficulty()};column.addArrangedSubview(difficulty)
        column.addArrangedSubview(button(CatalogText.ui("select_tricks"),icon:.training){[weak self] in self?.router?.show(.selectDailyTricks)})
        column.addArrangedSubview(button(MainText.text("play_day_streak"),icon:.daily){[weak self] in self?.router?.show(.daily)})
        status=label("",role:.caption);status.textAlignment = .center;column.addArrangedSubview(status)
        column.addArrangedSubview(button(CatalogText.ui("notification_system_settings"),icon:.settings,kind:.compact){if let url=URL(string:UIApplication.openSettingsURLString){UIApplication.shared.open(url)}})
    }
    override func update(_ progress:ProgressState?){
        if !busy {enabled.setOn(progress?.daily.notificationsEnabled==true,animated:false)}
        enabled.onTintColor=palette.switchOnTint;enabled.isEnabled=progress != nil;enabled.isUserInteractionEnabled = !busy
        let reminder=settings.dailyReminder ?? DailyReminderSettings()
        let date=Calendar.current.date(from:DateComponents(hour:reminder.hour,minute:reminder.minute)) ?? Date()
        let selected=Calendar.current.dateComponents([.hour,.minute],from:time.date)
        if !busy && (selected.hour != reminder.hour || selected.minute != reminder.minute) {time.setDate(date,animated:false)}
        time.isEnabled=progress != nil;time.isUserInteractionEnabled = !busy
        goal.label.text=CatalogText.ui("daily_goal")+": \(progress?.daily.target ?? 5)"
        difficulty.label.text=CatalogText.ui("difficulty")+": \(reminder.difficulty)"
        goal.isEnabled=progress != nil;difficulty.isEnabled=progress != nil
        goal.isUserInteractionEnabled = !busy;difficulty.isUserInteractionEnabled = !busy
        if let daily=progress?.daily {status.text=MainText.format("day_streak_today","\(daily.solved)/\(daily.target)")+" · "+MainText.format("day_streak_text",String(daily.streak))}
    }
    @objc private func enableChanged(){
        guard !busy else{return};let requested=enabled.isOn;busy=true;update(data.snapshot)
        Task{[weak self] in guard let self else{return};do{
            let permitted=try await DailyNotificationService.shared.setEnabled(requested,data:data)
            if requested && !permitted {present(AppDialogViewController(title:MainText.text("enable_notifications"),message:CatalogText.ui("notification_denied"),actions:[.init(title:MainText.text("ok"),handler:{})],data:data),animated:false)}
        }catch{showError(error)};busy=false;update(data.snapshot)}
    }
    @objc private func timeChanged(){let parts=Calendar.current.dateComponents([.hour,.minute],from:time.date);save(.time(hour:parts.hour ?? 12,minute:parts.minute ?? 0))}
    private func save(_ change:DailyOptionsChange){
        guard !busy else{return};busy=true;update(data.snapshot)
        Task{[weak self] in guard let self else{return};do{try await data.updateDailyOptions(change);try await DailyNotificationService.shared.schedule(data.snapshot)}catch{showError(error)};busy=false;update(data.snapshot)}
    }
    private func chooseGoal(){choose(title:CatalogText.ui("daily_goal"),values:[1,2,3,4,5,10,20,30,40,50,75,100],current:data.snapshot?.daily.target ?? 5){[weak self] in self?.save(.target($0))}}
    private func chooseDifficulty(){choose(title:CatalogText.ui("difficulty"),values:Array(1...20)+Array(stride(from:25,through:100,by:5)),current:(settings.dailyReminder ?? DailyReminderSettings()).difficulty){[weak self] in self?.save(.difficulty($0))}}
    private func choose(title:String,values:[Int],current:Int,selection:@escaping (Int)->Void){
        let dialog=ResultSelectionViewController(title:title,values:values.map(String.init),selection:values.firstIndex(of:current) ?? -1,settings:settings,anchor:nil){index in
            selection(values[index])
        }
        present(dialog,animated:false)
    }
}
