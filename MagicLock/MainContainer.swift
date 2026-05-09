import SwiftUI

struct MainContainer: View {
    @ObservedObject var state: AppState
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            // — Main screens —
            switch state.screenState {
            case .locked:
                LockScreenView(state: state)
                    .transition(.opacity)
            case .passcode:
                PasscodeView(state: state)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .home:
                HomeScreenView(state: state)
                    .transition(.opacity)
            }

            // — Settings sheet —
            if showingSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation { showingSettings = false }
                    }

                SettingsView(state: state, isPresented: $showingSettings)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(200)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: state.screenState)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenSettings"))) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                showingSettings = true
            }
        }
    }
}

// MARK: - Settings View (Performer Config)

struct SettingsView: View {
    @ObservedObject var state: AppState
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // — Handle —
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                ScrollView {
                    VStack(spacing: 20) {

                        // MARK: Screen State
                        settingsSection(title: "Screen") {
                            Picker("State", selection: $state.screenState) {
                                Text("Lock Screen").tag(ScreenState.locked)
                                Text("Passcode").tag(ScreenState.passcode)
                                Text("Home Screen").tag(ScreenState.home)
                            }
                            .pickerStyle(.segmented)
                        }

                        // MARK: Passcode
                        settingsSection(title: "Passcode") {
                            HStack(spacing: 12) {
                                ForEach(0..<4, id: \.self) { i in
                                    TextField("", text: Binding(
                                        get: {
                                            i < state.targetPasscode.count
                                                ? "\(state.targetPasscode[i])" : ""
                                        },
                                        set: { val in
                                            if let d = Int(val.prefix(1)),
                                               i < state.targetPasscode.count {
                                                state.targetPasscode[i] = d
                                            }
                                        }
                                    ))
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                                    .multilineTextAlignment(.center)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                }
                            }
                        }

                        // MARK: Time Override
                        settingsSection(title: "Time Override") {
                            DatePicker("", selection: Binding(
                                get: { state.currentTime },
                                set: { state.timeOffset = $0.timeIntervalSince(Date()) }
                            ))
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                        }

                        // MARK: Battery
                        settingsSection(title: "Battery: \(Int(state.batteryLevel * 100))%") {
                            Slider(value: $state.batteryLevel, in: 0...1, step: 0.01)
                                .tint(.green)
                            Toggle("Charging", isOn: $state.isCharging)
                                .tint(.green)
                        }

                        // MARK: Actions
                        settingsSection(title: "Actions") {
                            Button(action: {
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    state.triggerAutoUnlock()
                                }
                            }) {
                                Label("Trigger Auto Unlock", systemImage: "lock.open.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }

                            Button(action: {
                                state.reset()
                                isPresented = false
                            }) {
                                Label("Reset to Lock Screen", systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .edgesIgnoringSafeArea(.bottom)
                    .environment(\.colorScheme, .dark)
            )
        }
    }

    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
            content()
        }
    }
}
