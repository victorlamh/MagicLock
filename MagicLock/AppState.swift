import SwiftUI
import Combine

// MARK: - Screen States

enum ScreenState: Equatable {
    case locked
    case passcode
    case home
}

// MARK: - App State

class AppState: ObservableObject {
    // Current screen
    @Published var screenState: ScreenState = .locked

    // Time & Date
    @Published var timeOffset: TimeInterval = 0
    @Published var currentTime: Date = Date()

    // Battery
    @Published var batteryLevel: Double = 0.85
    @Published var isCharging: Bool = false

    // Passcode
    @Published var enteredDigits: [Int] = []
    @Published var targetPasscode: [Int] = [1, 2, 3, 4]
    @Published var isAutoTyping: Bool = false
    @Published var passcodeShake: Bool = false

    // Notifications
    @Published var notifications: [FakeNotification] = []

    private var timer: AnyCancellable?

    init() {
        startClock()
    }

    // MARK: — Clock

    func startClock() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentTime = Date().addingTimeInterval(self.timeOffset)
            }
    }

    // MARK: — Reset

    func reset() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            screenState = .locked
        }
        enteredDigits = []
        isAutoTyping = false
    }

    // MARK: — Auto Unlock Routine

    func triggerAutoUnlock() {
        guard !isAutoTyping else { return }
        isAutoTyping = true
        enteredDigits = []

        if screenState == .locked {
            // First: transition to passcode screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    self.screenState = .passcode
                }
                // Then start auto-typing after brief pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.autoTypeSequence()
                }
            }
        } else if screenState == .passcode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.autoTypeSequence()
            }
        }
    }

    private func autoTypeSequence() {
        var delay: Double = 0
        for digit in targetPasscode {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard self.isAutoTyping else { return }
                self.enterDigit(digit)
            }
            delay += 0.35
        }
    }

    // MARK: — Digit Entry

    func enterDigit(_ digit: Int) {
        guard enteredDigits.count < 4 else { return }
        enteredDigits.append(digit)

        if enteredDigits.count == 4 {
            if enteredDigits == targetPasscode {
                // Success: unlock after brief pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                        self.screenState = .home
                    }
                    self.isAutoTyping = false
                }
            } else {
                // Wrong code: shake and clear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.passcodeShake = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.enteredDigits = []
                        self.passcodeShake = false
                        self.isAutoTyping = false
                    }
                }
            }
        }
    }
}

// MARK: - Notification Model

struct FakeNotification: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let body: String
    let timestamp: String
    let appIcon: String
}
