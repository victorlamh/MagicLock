import SwiftUI

@main
struct MagicLockApp: App {
    @StateObject var state = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainContainer(state: state)
                .preferredColorScheme(.dark)
        }
    }
}
