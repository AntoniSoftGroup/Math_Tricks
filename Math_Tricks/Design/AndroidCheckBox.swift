import UIKit

/// Original 30 dp Android check drawables inside a 48 pt touch area.
final class AndroidCheckBox:UIControl {
    private let image=UIImageView()
    var isOn=false {didSet{refresh()}}
    var onTintColor:UIColor? {didSet{refresh()}}
    override var isEnabled:Bool {didSet{alpha=isEnabled ? 1:0.5}}
    override var intrinsicContentSize:CGSize {CGSize(width:48,height:48)}
    override init(frame:CGRect) {
        super.init(frame:frame)
        translatesAutoresizingMaskIntoConstraints=false;isAccessibilityElement=true
        image.translatesAutoresizingMaskIntoConstraints=false;image.contentMode = .scaleAspectFit;addSubview(image)
        NSLayoutConstraint.activate([image.centerXAnchor.constraint(equalTo:centerXAnchor),image.centerYAnchor.constraint(equalTo:centerYAnchor),image.widthAnchor.constraint(equalToConstant:30),image.heightAnchor.constraint(equalToConstant:30)])
        addAction(UIAction{[weak self] _ in self?.toggle()},for:.touchUpInside);refresh()
    }
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    func setOn(_ on:Bool,animated:Bool){isOn=on}
    private func toggle(){guard isEnabled else{return};isOn.toggle();sendActions(for:.valueChanged)}
    override func accessibilityActivate()->Bool{guard isEnabled else{return false};toggle();return true}
    private func refresh(){image.image=UIImage(named:isOn ? "ic_th_light_cb_trick_on":"ic_th_light_cb_trick_off")?.withTintColor(onTintColor ?? .label,renderingMode:.alwaysOriginal);accessibilityTraits=isOn ? [.button,.selected]:.button}
}
