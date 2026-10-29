import UIKit
import AVFAudio
import CoreHaptics
import Combine

nonisolated enum AppSound: String, CaseIterable, Sendable {
    case keypress = "keypress_standard"
    case levelComplete = "level_complete"
    case solution = "solution_is_answer"
    case coins = "drop_coins"
    case starLost = "star_lose"
    case timerEnd = "timer_end"
    case error, wrong
    case switchNumpad = "switch_numpad"

    var fileExtension: String { self == .error ? "wav" : "mp3" }
}

enum AppHaptic {
    case step, correct, inputError, wrong, levelComplete, timerEnd
    var duration: TimeInterval {
        switch self {
        case .step: 0.03
        case .correct: 0.05
        case .inputError: 0.06
        case .wrong: 0.25
        case .levelComplete, .timerEnd: 0.5
        }
    }
}

/// Short foreground effects only. No alarm audio, microphone or background mode.
@MainActor
final class AppFeedback {
    static let shared = AppFeedback(data: .shared)
    private let data: AppDataStore
    private var hapticEngine: CHHapticEngine?
    private var hapticPlayer: CHHapticPatternPlayer?
    private let sounds = SoundPlayback()
    private var observations = Set<AnyCancellable>()

    private init(data: AppDataStore) {
        self.data = data
        let notifications = NotificationCenter.default
        notifications.publisher(for: UIApplication.didEnterBackgroundNotification)
            .merge(with: notifications.publisher(for: AVAudioSession.interruptionNotification))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.stop() }
            .store(in: &observations)
        notifications.publisher(for:UIApplication.didBecomeActiveNotification)
            .receive(on:RunLoop.main)
            .sink { [weak self] _ in self?.prepareSounds() }
            .store(in:&observations)
        data.$snapshot.sink { [weak self] progress in
            self?.sounds.setEnabled(progress?.settings.soundEnabled == true && UIApplication.shared.applicationState == .active)
        }.store(in:&observations)
    }

    private func prepareSounds() {
        sounds.setEnabled(data.snapshot?.settings.soundEnabled == true && UIApplication.shared.applicationState == .active)
    }

    func play(_ sound: AppSound, volume: Float = 1) {
        prepareSounds()
        sounds.play(sound,volume:volume)
    }

    func haptic(_ kind: AppHaptic) {
        guard data.snapshot?.settings.vibrationEnabled == true,
              UIApplication.shared.applicationState == .active else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6)
            return
        }
        do {
            if hapticEngine == nil { hapticEngine = try CHHapticEngine() }
            guard let hapticEngine else { return }
            try hapticEngine.start()
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ], relativeTime: 0, duration: kind.duration)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
            hapticPlayer = try hapticEngine.makePlayer(with: pattern)
            try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            hapticPlayer = nil; hapticEngine = nil
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6)
            NSLog("Game haptic: %@", error.localizedDescription)
        }
    }

    func stop() { sounds.setEnabled(false) }
}

// Player state stays on the audio queue; the lock only protects availability and cancellation.
nonisolated private final class SoundPlayback: @unchecked Sendable {
    private let queue = DispatchQueue(label:"com.antoni.mathtricks.sound",qos:.userInitiated)
    private let lock = NSLock()
    private var enabled = false
    private var ready = false
    private var generation = 0
    private var sessionActive = false
    private var soundData: [AppSound:Data] = [:]
    private var prepared: [AppSound:AVAudioPlayer] = [:]
    private var playing: [AVAudioPlayer] = []

    func setEnabled(_ value: Bool) {
        lock.lock()
        guard enabled != value else { lock.unlock(); return }
        enabled = value; ready = false; generation += 1
        let current = generation
        lock.unlock()
        queue.async {
            if value { self.prepare(generation:current) }
            else { self.stopOnQueue() }
        }
    }

    private func isCurrent(_ current: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return enabled && generation == current
    }

    private func prepare(generation current: Int) {
        dispatchPrecondition(condition:.onQueue(queue))
        guard isCurrent(current) else { return }
        let began = ProcessInfo.processInfo.systemUptime
        do {
            let session = AVAudioSession.sharedInstance()
            // Ambient respects the silent switch and mixes with existing music.
            try session.setCategory(.ambient,mode:.default,options:[.mixWithOthers])
            try session.setActive(true)
            sessionActive = true
            for sound in AppSound.allCases {
                guard isCurrent(current) else { return }
                do {
                    if soundData[sound] == nil {
                        guard let url = Bundle.main.url(forResource:sound.rawValue,withExtension:sound.fileExtension) else {
                            NSLog("Missing sound: %@",sound.rawValue); continue
                        }
                        soundData[sound] = try Data(contentsOf:url)
                    }
                    guard let bytes = soundData[sound] else { continue }
                    if prepared[sound] == nil { prepared[sound] = try AVAudioPlayer(data:bytes) }
                    prepared[sound]?.prepareToPlay()
                } catch { NSLog("Sound preparation %@: %@",sound.rawValue,error.localizedDescription) }
            }
            lock.lock()
            if enabled && generation == current { ready = true }
            lock.unlock()
            NSLog("Sound preload: %.3f s",ProcessInfo.processInfo.systemUptime - began)
        } catch {
            lock.lock()
            if generation == current { enabled = false; ready = false }
            lock.unlock()
            stopOnQueue()
            NSLog("Sound preparation: %@",error.localizedDescription)
        }
    }

    func play(_ sound: AppSound, volume: Float) {
        lock.lock()
        let canPlay = enabled && ready
        let current = generation
        lock.unlock()
        // Skip effects during warmup instead of replaying old taps when preparation finishes.
        guard canPlay else { return }
        queue.async {
            dispatchPrecondition(condition:.onQueue(self.queue))
            guard self.isCurrent(current), let cached = self.prepared[sound] else { return }
            do {
                self.playing.removeAll { !$0.isPlaying }
                if self.playing.count >= 5 { self.playing.removeFirst().stop() }
                let player: AVAudioPlayer
                if cached.isPlaying, let bytes = self.soundData[sound] { player = try AVAudioPlayer(data:bytes) }
                else { player = cached }
                player.volume = max(0,min(1,volume)); player.currentTime = 0
                guard self.isCurrent(current) else { return }
                if player.play() { self.playing.append(player) }
            } catch { NSLog("Sound playback: %@",error.localizedDescription) }
        }
    }

    private func stopOnQueue() {
        dispatchPrecondition(condition:.onQueue(queue))
        playing.forEach { $0.stop() }; playing.removeAll()
        prepared.values.forEach { $0.stop() }
        // Do not restart interrupted effects after returning to the app.
        if sessionActive {
            try? AVAudioSession.sharedInstance().setActive(false,options:.notifyOthersOnDeactivation)
            sessionActive = false
        }
    }
}
