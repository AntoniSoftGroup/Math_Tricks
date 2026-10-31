import UIKit

final class DailySettingsViewController:ThemedViewController {
    private let enabled=UISwitch()
    private let time=UIDatePicker()
    private var goal:AppButton!
    private var difficulty:AppButton!
    private var status:AppLabel!
    private var busy=false
    private var originalColumn: UIStackView!
    private var originalControls: [UIView] = []
    private var reminderControls: [UIView] = []
    private var split: AppDuoSplitView?
    private var reminderColumn: UIStackView?
    private var practiceColumn: UIStackView?
    private var usesSplit = false
    override func buildContent(){
        view.accessibilityIdentifier="screen.dailySettings"
        let column=scrollStack()
        originalColumn = column
        let row=UIStackView(arrangedSubviews:[label(MainText.text("enable_notifications")),enabled]);row.alignment = .center;column.addArrangedSubview(row)
        enabled.addTarget(self,action:#selector(enableChanged),for:.valueChanged)
        time.datePickerMode = .time;time.preferredDatePickerStyle = .wheels;time.addTarget(self,action:#selector(timeChanged),for:.valueChanged);column.addArrangedSubview(time)
        goal=button(""){[weak self] in self?.chooseGoal()};column.addArrangedSubview(goal)
        difficulty=button(""){[weak self] in self?.chooseDifficulty()};column.addArrangedSubview(difficulty)
        column.addArrangedSubview(button(CatalogText.ui("select_tricks"),icon:.training){[weak self] in self?.router?.show(.selectDailyTricks)})
        column.addArrangedSubview(button(MainText.text("play_day_streak"),icon:.daily){[weak self] in self?.router?.show(.daily)})
        status=label("",role:.caption);status.textAlignment = .center;column.addArrangedSubview(status)
        let systemSettings = button(CatalogText.ui("notification_system_settings"),icon:.settings,kind:.compact){if let url=URL(string:UIApplication.openSettingsURLString){UIApplication.shared.open(url)}}
        column.addArrangedSubview(systemSettings)
        originalControls = column.arrangedSubviews
        reminderControls = [row, time, systemSettings]
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let needsSplit = AppDuoGameArrangement.canUse(in: body)
        guard needsSplit != usesSplit else { return }
        usesSplit = needsSplit
        if needsSplit, split == nil {
            let panes = AppDuoSplitView()
            panes.axis = view.bounds.width > view.bounds.height ? .horizontal : .vertical
            panes.distribution = .fillEqually
            panes.translatesAutoresizingMaskIntoConstraints = false
            body.addSubview(panes)
            NSLayoutConstraint.activate([
                panes.topAnchor.constraint(equalTo: body.topAnchor), panes.bottomAnchor.constraint(equalTo: body.bottomAnchor),
                panes.leadingAnchor.constraint(equalTo: body.leadingAnchor), panes.trailingAnchor.constraint(equalTo: body.trailingAnchor)
            ])
            let reminder = UIView(), practice = UIView()
            panes.addArrangedSubview(reminder); panes.addArrangedSubview(practice)
            reminderColumn = scrollStack(in: reminder)
            practiceColumn = scrollStack(in: practice)
            split = panes
        }
        for control in originalControls {
            (control.superview as? UIStackView)?.removeArrangedSubview(control)
            control.removeFromSuperview()
        }
        if needsSplit {
            reminderControls.forEach { reminderColumn?.addArrangedSubview($0) }
            originalControls.filter { control in !reminderControls.contains { $0 === control } }
                .forEach { practiceColumn?.addArrangedSubview($0) }
        } else {
            originalControls.forEach { originalColumn.addArrangedSubview($0) }
        }
        originalColumn.superview?.isHidden = needsSplit
        split?.isHidden = !needsSplit
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
