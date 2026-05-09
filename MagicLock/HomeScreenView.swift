import SwiftUI

// MARK: - Fake Home Screen (iOS 17 style)

struct HomeScreenView: View {
    @ObservedObject var state: AppState
    @State private var appeared = false

    // Realistic app grid: (name, SF Symbol, gradient colors)
    let topApps: [(String, String, [Color])] = [
        // Row 1
        ("Messages", "message.fill", [.green, Color(red: 0.2, green: 0.7, blue: 0.3)]),
        ("Calendar", "calendar", [.white, Color(red: 0.95, green: 0.95, blue: 0.95)]),
        ("Photos", "photo.fill", [Color(red: 1.0, green: 0.6, blue: 0.2), .yellow, .green, .blue, .purple]),
        ("Camera", "camera.fill", [Color(red: 0.3, green: 0.3, blue: 0.35), Color(red: 0.15, green: 0.15, blue: 0.2)]),
        // Row 2
        ("Weather", "cloud.sun.fill", [Color(red: 0.3, green: 0.65, blue: 0.95), Color(red: 0.15, green: 0.45, blue: 0.85)]),
        ("Clock", "clock.fill", [.black, Color(red: 0.1, green: 0.1, blue: 0.1)]),
        ("Maps", "map.fill", [Color(red: 0.2, green: 0.75, blue: 0.4), Color(red: 0.15, green: 0.6, blue: 0.3)]),
        ("Notes", "note.text", [.yellow, Color(red: 1.0, green: 0.9, blue: 0.5)]),
        // Row 3
        ("Reminders", "checklist", [.white, Color(red: 0.95, green: 0.95, blue: 0.95)]),
        ("Stocks", "chart.line.uptrend.xyaxis", [.black, Color(red: 0.1, green: 0.1, blue: 0.1)]),
        ("News", "newspaper.fill", [Color(red: 0.95, green: 0.25, blue: 0.3), Color(red: 0.85, green: 0.15, blue: 0.2)]),
        ("App Store", "bag.fill", [Color(red: 0.15, green: 0.55, blue: 0.95), Color(red: 0.1, green: 0.4, blue: 0.85)]),
        // Row 4
        ("Translate", "character.bubble.fill", [.white, Color(red: 0.95, green: 0.95, blue: 0.95)]),
        ("Health", "heart.fill", [.white, Color(red: 0.95, green: 0.95, blue: 0.95)]),
        ("Wallet", "creditcard.fill", [.black, Color(red: 0.1, green: 0.1, blue: 0.1)]),
        ("Settings", "gearshape.fill", [Color(red: 0.5, green: 0.5, blue: 0.55), Color(red: 0.35, green: 0.35, blue: 0.4)]),
        // Row 5
        ("Files", "folder.fill", [Color(red: 0.15, green: 0.55, blue: 0.95), Color(red: 0.1, green: 0.4, blue: 0.85)]),
        ("Tips", "lightbulb.fill", [.yellow, Color(red: 0.95, green: 0.8, blue: 0.1)]),
        ("Shortcuts", "square.stack.3d.up.fill", [
            Color(red: 0.2, green: 0.4, blue: 0.8),
            Color(red: 0.6, green: 0.2, blue: 0.5),
            Color(red: 0.9, green: 0.3, blue: 0.4)
        ]),
        ("Podcasts", "dot.radiowaves.left.and.right", [Color(red: 0.6, green: 0.2, blue: 0.8), Color(red: 0.5, green: 0.1, blue: 0.7)]),
    ]

    let dockApps: [(String, String, [Color])] = [
        ("Phone", "phone.fill", [Color(red: 0.2, green: 0.8, blue: 0.3), Color(red: 0.15, green: 0.65, blue: 0.25)]),
        ("Safari", "safari.fill", [Color(red: 0.2, green: 0.55, blue: 0.95), Color(red: 0.15, green: 0.45, blue: 0.85)]),
        ("Mail", "envelope.fill", [Color(red: 0.15, green: 0.55, blue: 0.95), Color(red: 0.1, green: 0.4, blue: 0.85)]),
        ("Music", "music.note", [Color(red: 0.95, green: 0.2, blue: 0.35), Color(red: 0.85, green: 0.1, blue: 0.3)]),
    ]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    var body: some View {
        ZStack {
            // — Background —
            homeWallpaper
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // — Status bar —
                homeStatusBar
                    .padding(.top, 14)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 18)

                // — App grid —
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(0..<topApps.count, id: \.self) { i in
                        let app = topApps[i]
                        AppIcon(name: app.0, symbol: app.1, colors: app.2)
                    }
                }
                .padding(.horizontal, 22)

                Spacer()

                // — Search pill —
                Text("Search")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .environment(\.colorScheme, .dark)
                    .padding(.bottom, 12)

                // — Page dots —
                HStack(spacing: 6) {
                    Circle().fill(Color.white).frame(width: 7, height: 7)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 7, height: 7)
                    Circle().fill(Color.white.opacity(0.35)).frame(width: 7, height: 7)
                }
                .padding(.bottom, 10)

                // — Dock —
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 100)
                        .padding(.horizontal, 10)
                        .environment(\.colorScheme, .dark)

                    HStack(spacing: 20) {
                        ForEach(0..<dockApps.count, id: \.self) { i in
                            let app = dockApps[i]
                            AppIcon(name: app.0, symbol: app.1, colors: app.2, showLabel: false)
                        }
                    }
                }

                // — Home indicator —
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 140, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.92)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }

    // MARK: — Status Bar

    private var homeStatusBar: some View {
        HStack {
            Text(state.currentTime.formatted(.dateTime.hour().minute()))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "cellularbars")
                    .font(.system(size: 12, weight: .semibold))
                Image(systemName: "wifi")
                    .font(.system(size: 13, weight: .semibold))
                BatteryView(level: state.batteryLevel, isCharging: state.isCharging)
            }
            .foregroundColor(.white)
        }
    }

    // MARK: — Background

    private var homeWallpaper: some View {
        ZStack {
            Color.black
            Canvas { context, size in
                let topCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.18)
                context.drawLayer { ctx in
                    let colors = Gradient(colors: [
                        Color(red: 0.55, green: 0.45, blue: 0.60).opacity(0.5),
                        Color(red: 0.20, green: 0.15, blue: 0.35).opacity(0.35),
                        Color.clear
                    ])
                    let gradient = ctx.resolveShading(.radialGradient(
                        colors, center: topCenter,
                        startRadius: 0, endRadius: size.width * 0.7
                    ))
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: gradient)
                }
                let bottomCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
                context.drawLayer { ctx in
                    let colors = Gradient(colors: [
                        Color(red: 0.15, green: 0.35, blue: 0.50).opacity(0.4),
                        Color(red: 0.05, green: 0.15, blue: 0.30).opacity(0.25),
                        Color.clear
                    ])
                    let gradient = ctx.resolveShading(.radialGradient(
                        colors, center: bottomCenter,
                        startRadius: 0, endRadius: size.width * 0.75
                    ))
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: gradient)
                }
            }
            // Slight blur on home for depth
            Color.black.opacity(0.15)
        }
    }
}

// MARK: - App Icon

struct AppIcon: View {
    let name: String
    let symbol: String
    let colors: [Color]
    var showLabel: Bool = true

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 62, height: 62)
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)

                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(iconForeground)
            }

            if showLabel {
                Text(name)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }

    private var iconForeground: Color {
        // Light icons get dark text
        let lightBackgrounds = ["Calendar", "Notes", "Reminders", "Translate", "Health"]
        if lightBackgrounds.contains(name) {
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
        return .white
    }
}
