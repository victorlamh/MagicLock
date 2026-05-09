import SwiftUI

struct LockScreenView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        ZStack {
            // Wallpaper
            Image(state.wallpaperImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.1)) // Subtle depth
            
            VStack {
                Spacer()
                    .frame(height: 60)
                
                // Date
                Text(state.currentTime.formatted(.dateTime.weekday(.wide).month(.wide).day(.defaultDigits)))
                    .font(.system(size: 22, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                // Time
                Text(state.currentTime.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 96, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, -10)
                
                Spacer()
                
                // Notifications could go here
                if !state.notifications.isEmpty {
                    NotificationStack(notifications: state.notifications)
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    CircleButton(icon: "flashlight.off.fill")
                    Spacer()
                    CircleButton(icon: "camera.fill")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                
                // Home Indicator / Swipe Text
                VStack(spacing: 8) {
                    Text("Swipe up to unlock")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 140, height: 5)
                }
                .padding(.bottom, 10)
            }
            
            // Status Bar Overlay
            VStack {
                HStack {
                    Spacer()
                    StatusBarView(state: state)
                }
                .padding(.horizontal, 30)
                .padding(.top, 15)
                Spacer()
            }
        }
    }
}

struct CircleButton: View {
    let icon: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }
}

struct StatusBarView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "cellularbars")
            Image(systemName: "wifi")
            HStack(spacing: 2) {
                Text("\(Int(state.batteryLevel * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                Image(systemName: state.isCharging ? "battery.100.bolt" : "battery.100")
            }
        }
        .foregroundColor(.white)
        .font(.system(size: 14))
    }
}

struct NotificationStack: View {
    let notifications: [FakeNotification]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(notifications.prefix(3)) { note in
                HStack {
                    Image(systemName: note.appIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(5)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(note.title).bold()
                            Spacer()
                            Text(note.timestamp).font(.caption)
                        }
                        Text(note.body).font(.subheadline)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
            }
        }
    }
}
