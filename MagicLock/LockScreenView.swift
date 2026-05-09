import SwiftUI

// MARK: - Lock Screen (iOS 16+ style, pixel-perfect)

struct LockScreenView: View {
    @ObservedObject var state: AppState
    @State private var swipeOffset: CGFloat = 0
    @State private var isAwake: Bool = true
    @State private var screenBrightness: Double = 1.0

    var body: some View {
        ZStack {
            // — Background wallpaper or gradient —
            lockWallpaper
                .edgesIgnoringSafeArea(.all)

            // — Main lock-screen content —
            VStack(spacing: 0) {

                // — Status bar —
                iOSStatusBar
                    .padding(.top, 14)

                Spacer().frame(height: 8)

                // — Lock icon —
                Image(systemName: "lock.fill")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.bottom, 10)

                // — Date line —
                Text(formattedDate)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .kerning(0.2)

                // — Time —
                Text(formattedTime)
                    .font(.system(size: 82, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .kerning(1.5)
                    .padding(.top, -8)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("OpenSettings"), object: nil
                        )
                    }

                Spacer()

                // — Notification area —
                if !state.notifications.isEmpty {
                    notificationStack
                        .padding(.bottom, 16)
                }

                Spacer()

                // — Bottom controls —
                bottomControls
                    .padding(.bottom, 16)

                // — Home indicator —
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 140, height: 5)
                    .padding(.bottom, 8)
            }

            // — Sleep overlay —
            Color.black
                .opacity(isAwake ? 0 : 1)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(!isAwake)
                .onTapGesture {
                    wakeUp()
                }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onChanged { value in
                    if value.translation.height < 0 {
                        swipeOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -100 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            state.screenState = .passcode
                        }
                    }
                    swipeOffset = 0
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SleepScreen"))) { _ in
            sleep()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WakeScreen"))) { _ in
            wakeUp()
        }
    }

    // MARK: — Formatted strings

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: state.currentTime)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMMM"
        return f.string(from: state.currentTime)
    }

    // MARK: — Background

    private var lockWallpaper: some View {
        ZStack {
            Color.black
            // Two-orb iOS-style abstract wallpaper
            Canvas { context, size in
                let rect = Path(CGRect(origin: .zero, size: size))

                // Top orb (warm)
                let topCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.18)
                let topRadius: CGFloat = size.width * 0.7
                let topColors = Gradient(colors: [
                    Color(red: 0.55, green: 0.45, blue: 0.60).opacity(0.7),
                    Color(red: 0.20, green: 0.15, blue: 0.35).opacity(0.5),
                    Color.clear
                ])
                context.fill(rect, with: .radialGradient(
                    topColors, center: topCenter,
                    startRadius: 0, endRadius: topRadius
                ))

                // Bottom orb (cool blue/teal)
                let bottomCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
                let bottomRadius: CGFloat = size.width * 0.75
                let bottomColors = Gradient(colors: [
                    Color(red: 0.15, green: 0.35, blue: 0.50).opacity(0.6),
                    Color(red: 0.05, green: 0.15, blue: 0.30).opacity(0.4),
                    Color.clear
                ])
                context.fill(rect, with: .radialGradient(
                    bottomColors, center: bottomCenter,
                    startRadius: 0, endRadius: bottomRadius
                ))

                // Subtle light line intersection
                let mid = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
                let midColors = Gradient(colors: [
                    Color.white.opacity(0.06),
                    Color.clear
                ])
                context.fill(rect, with: .radialGradient(
                    midColors, center: mid,
                    startRadius: 0, endRadius: size.width * 0.5
                ))
            }
        }
    }

    // MARK: — Status Bar (iOS style)

    private var iOSStatusBar: some View {
        HStack {
            // Left: Time (on lock screen this is empty, time is the main display)
            // But we need spacer for balance
            Spacer()

            // Right cluster
            HStack(spacing: 4) {
                // Cellular
                Image(systemName: "cellularbars")
                    .font(.system(size: 12, weight: .semibold))
                // Wi-Fi
                Image(systemName: "wifi")
                    .font(.system(size: 13, weight: .semibold))
                // Battery
                BatteryView(level: state.batteryLevel, isCharging: state.isCharging)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
    }

    // MARK: — Bottom Controls

    private var bottomControls: some View {
        HStack {
            // Flashlight
            LockScreenButton(icon: "flashlight.off.fill", iconSize: 18)
            Spacer()
            // Camera
            LockScreenButton(icon: "camera.fill", iconSize: 17)
        }
        .padding(.horizontal, 46)
    }

    // MARK: — Notifications

    private var notificationStack: some View {
        VStack(spacing: 10) {
            ForEach(state.notifications.prefix(3)) { note in
                HStack(spacing: 12) {
                    Image(systemName: note.appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(note.title)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text(note.timestamp)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        if !note.subtitle.isEmpty {
                            Text(note.subtitle)
                                .font(.system(size: 14, weight: .medium))
                        }
                        Text(note.body)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: — Sleep / Wake

    private func sleep() {
        withAnimation(.easeOut(duration: 0.3)) {
            isAwake = false
        }
    }

    private func wakeUp() {
        withAnimation(.easeIn(duration: 0.2)) {
            isAwake = true
        }
    }
}

// MARK: - Lock Screen Button (Flashlight / Camera)

struct LockScreenButton: View {
    let icon: String
    var iconSize: CGFloat = 18
    @State private var isPressed = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 50, height: 50)
                .environment(\.colorScheme, .dark)

            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.white)
        }
        .scaleEffect(isPressed ? 1.15 : 1.0)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Battery View (Native-accurate)

struct BatteryView: View {
    let level: Double
    let isCharging: Bool

    var body: some View {
        HStack(spacing: 1) {
            ZStack(alignment: .leading) {
                // Battery outline
                RoundedRectangle(cornerRadius: 2.5)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    .frame(width: 25, height: 11.5)

                // Battery fill
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(batteryColor)
                    .frame(width: max(2, CGFloat(level) * 21), height: 7.5)
                    .padding(.leading, 2)

                // Charging bolt
                if isCharging {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(level > 0.5 ? .black : .white)
                        .frame(width: 25, height: 11.5)
                }
            }
            // Battery nub
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.5))
                .frame(width: 1.5, height: 4.5)
        }
    }

    private var batteryColor: Color {
        if isCharging { return .green }
        if level <= 0.2 { return .red }
        return .white
    }
}
