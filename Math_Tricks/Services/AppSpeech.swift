import AVFoundation
import UIKit
import Combine

@MainActor
final class AppSpeech {
    static let isEnabled = false // TTS is temporarily disabled.
    static let shared=AppSpeech()
    private lazy var speaker=AVSpeechSynthesizer()
    private var observation:AnyCancellable?
    private init(){guard Self.isEnabled else{return};observation=NotificationCenter.default.publisher(for:UIApplication.willResignActiveNotification).receive(on:RunLoop.main).sink{[weak self] _ in self?.stop()}}
    private func allowed(_ settings:AppSettings)->Bool{Self.isEnabled && settings.soundEnabled && (settings.speechMode ?? 0)>0 && UIApplication.shared.applicationState == .active}
    private func enqueue(_ text:String){
        try? AVAudioSession.sharedInstance().setCategory(.ambient,mode:.default,options:[.mixWithOthers])
        let utterance=AVSpeechUtterance(string:text)
        utterance.voice=AVSpeechSynthesisVoice(language:Locale.preferredLanguages.first ?? "en-US");utterance.rate=AVSpeechUtteranceDefaultSpeechRate;speaker.speak(utterance)
    }
    func speak(_ example:MathExample,settings:AppSettings){guard allowed(settings) else{return};stop();enqueue(MathExpressionFormatter.text(example))}
    func accepted(previous:MathExample,next:MathExample?,settings:AppSettings){
        guard allowed(settings) else{return};stop()
        if settings.speechMode==2{enqueue(MathExpressionFormatter.text(previous)+" = \(previous.answer)")}
        if let next{enqueue(MathExpressionFormatter.text(next))}
    }
    func stop(){guard Self.isEnabled else{return};speaker.stopSpeaking(at:.immediate)}
}
