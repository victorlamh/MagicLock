import SwiftUI

struct TriggerOverlay: View {
    @ObservedObject var state: AppState
    @State private var sequence: [Int] = []
    @State private var timer: Timer?
    
    // Configurable trigger sequence
    let triggerSequence = [0, 1] // Top-Left, then Top-Right
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Invisible Hit Zones
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TriggerZone(id: 0, action: handleTap) // Top-Left
                        TriggerZone(id: 1, action: handleTap) // Top-Right
                    }
                    HStack(spacing: 0) {
                        TriggerZone(id: 2, action: handleTap) // Bottom-Left
                        TriggerZone(id: 3, action: handleTap) // Bottom-Right
                    }
                }
                
                // Hidden Settings Trigger (Long press top center)
                Color.clear
                    .frame(width: 100, height: 40)
                    .contentShape(Rectangle())
                    .position(x: geo.size.width / 2, y: 20)
                    .onLongPressGesture(minimumDuration: 2.0) {
                        NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
                    }
            }
        }
    }
    
    func handleTap(_ id: Int) {
        sequence.append(id)
        
        // Reset sequence after 2 seconds of inactivity
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.sequence = []
        }
        
        // Check if sequence matches
        if sequence.suffix(triggerSequence.count) == triggerSequence {
            state.triggerAutoUnlock()
            sequence = []
        }
    }
}

struct TriggerZone: View {
    let id: Int
    let action: (Int) -> Void
    
    var body: some View {
        Color.white.opacity(0.001) // Invisible but catchable
            .contentShape(Rectangle())
            .onTapGesture {
                action(id)
            }
    }
}
