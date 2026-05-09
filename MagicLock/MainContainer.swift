import SwiftUI

struct MainContainer: View {
    @ObservedObject var state: AppState
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Main Content
            Group {
                switch state.screenState {
                case .locked:
                    LockScreenView(state: state)
                case .passcode:
                    PasscodeView(state: state)
                case .home:
                    HomeScreenView(state: state)
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 1.1)),
                removal: .opacity
            ))
            
            // Hidden Gestures Overlay
            TriggerOverlay(state: state)
            
            // Performer Control (only visible when triggered)
            if showingSettings {
                SettingsView(state: state, isPresented: $showingSettings)
                    .transition(.move(edge: .bottom))
                    .zIndex(100)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenSettings"))) { _ in
            withAnimation {
                showingSettings = true
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var state: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section("Core Settings") {
                    Picker("Screen", selection: $state.screenState) {
                        Text("Locked").tag(ScreenState.locked)
                        Text("Passcode").tag(ScreenState.passcode)
                        Text("Home").tag(ScreenState.home)
                    }
                    
                    TextField("Passcode (e.g. 1234)", text: Binding(
                        get: { state.targetPasscode.map(String.init).joined() },
                        set: { state.targetPasscode = $0.compactMap { Int(String($0)) } }
                    ))
                    .keyboardType(.numberPad)
                }
                
                Section("Overrides") {
                    DatePicker("Time Offset", selection: Binding(
                        get: { state.currentTime },
                        set: { state.timeOffset = $0.timeIntervalSince(Date()) }
                    ))
                    
                    Slider(value: $state.batteryLevel, in: 0...1, step: 0.01) {
                        Text("Battery: \(Int(state.batteryLevel * 100))%")
                    }
                    Toggle("Charging", isOn: $state.isCharging)
                }
                
                Section("Routines") {
                    Button("Trigger Auto Unlock") {
                        isPresented = false
                        state.triggerAutoUnlock()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset App") {
                        state.reset()
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Performer Config")
            .navigationBarItems(trailing: Button("Done") {
                withAnimation { isPresented = false }
            })
        }
    }
}
