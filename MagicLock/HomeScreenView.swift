import SwiftUI

struct HomeScreenView: View {
    @ObservedObject var state: AppState
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Wallpaper
            Image(state.wallpaperImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Status Bar
                HStack {
                    Text(state.currentTime.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    StatusBarView(state: state)
                }
                .padding(.horizontal, 30)
                .padding(.top, 15)
                
                // App Grid
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(0..<20) { i in
                        AppIconView(name: "App \(i + 1)")
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 25)
                
                Spacer()
                
                // Dock
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .frame(height: 95)
                        .padding(.horizontal, 15)
                    
                    HStack(spacing: 25) {
                        AppIconView(name: "Phone", showLabel: false)
                        AppIconView(name: "Safari", showLabel: false)
                        AppIconView(name: "Messages", showLabel: false)
                        AppIconView(name: "Music", showLabel: false)
                    }
                }
                .padding(.bottom, 30)
                
                // Home Indicator
                Capsule()
                    .fill(Color.white)
                    .frame(width: 140, height: 5)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct AppIconView: View {
    let name: String
    var showLabel: Bool = true
    
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [.gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(name.prefix(1)))
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            if showLabel {
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}
