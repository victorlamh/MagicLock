import SwiftUI
import Combine

enum ScreenState {
    case locked
    case passcode
    case home
}

class AppState: ObservableObject {
    @Published var screenState: ScreenState = .locked
    
    // Time & Date
    @Published var timeOffset: TimeInterval = 0
    @Published var timeScale: Double = 1.0
    @Published var currentTime: Date = Date()
    
    // Battery
    @Published var batteryLevel: Double = 0.85
    @Published var isCharging: Bool = false
    
    // Passcode
    @Published var enteredDigits: [Int] = []
    @Published var targetPasscode: [Int] = [1, 2, 3, 4]
    @Published var isAutoTyping: Bool = false
    
    // Notifications
    @Published var notifications: [FakeNotification] = []
    
    // Appearance
    @Published var wallpaperImage: String = "default_wallpaper" // Placeholder
    
    private var timer: AnyCancellable?
    
    init() {
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentTime = Date().addingTimeInterval(self.timeOffset)
            }
    }
    
    func reset() {
        screenState = .locked
        enteredDigits = []
        isAutoTyping = false
    }
    
    func triggerAutoUnlock() {
        guard !isAutoTyping else { return }
        isAutoTyping = true
        
        // Simulate wake if asleep
        if screenState == .locked {
            // Wait a bit, then move to passcode
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.screenState = .passcode
                }
                self.startAutoTyping()
            }
        } else if screenState == .passcode {
            startAutoTyping()
        }
    }
    
    private func startAutoTyping() {
        var delay = 0.5
        for digit in targetPasscode {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.isAutoTyping {
                    self.enterDigit(digit)
                }
            }
            delay += 0.4 // Native-feeling speed
        }
    }
    
    func enterDigit(_ digit: Int) {
        guard enteredDigits.count < 4 else { return }
        enteredDigits.append(digit)
        
        // Haptic feedback would be triggered here in a real app
        
        if enteredDigits.count == 4 {
            // Verify and transition
            if enteredDigits == targetPasscode {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.screenState = .home
                    }
                    self.isAutoTyping = false
                }
            } else {
                // Shake effect or reset
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.enteredDigits = []
                }
            }
        }
    }
}

struct FakeNotification: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let body: String
    let timestamp: String
    let appIcon: String
}
