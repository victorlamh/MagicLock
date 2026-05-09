import SwiftUI

struct PasscodeView: View {
    @ObservedObject var state: AppState
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient (blurred for passcode)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.0, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.2, blue: 0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 40)
            .overlay(Color.black.opacity(0.4))
            
            VStack {
                Spacer().frame(height: 100)
                
                Text("Enter Passcode")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Passcode Dots
                HStack(spacing: 20) {
                    ForEach(0..<4) { index in
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                            .background(state.enteredDigits.count > index ? Color.white : Color.clear)
                            .clipShape(Circle())
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.bottom, 60)
                
                // Keypad
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...9, id: \.self) { num in
                        KeypadButton(number: "\(num)", subtext: subtext(for: num)) {
                            state.enterDigit(num)
                        }
                    }
                    
                    // Bottom row
                    Spacer()
                    KeypadButton(number: "0", subtext: "") {
                        state.enterDigit(0)
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                HStack {
                    Button("Emergency") { }
                    Spacer()
                    Button(state.enteredDigits.isEmpty ? "Cancel" : "Delete") {
                        if !state.enteredDigits.isEmpty {
                            state.enteredDigits.removeLast()
                        } else {
                            withAnimation { state.screenState = .locked }
                        }
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
    
    func subtext(for num: Int) -> String {
        switch num {
        case 2: return "A B C"
        case 3: return "D E F"
        case 4: return "G H I"
        case 5: return "J K L"
        case 6: return "M N O"
        case 7: return "P Q R S"
        case 8: return "T U V"
        case 9: return "W X Y Z"
        default: return ""
        }
    }
}

struct KeypadButton: View {
    let number: String
    let subtext: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            // Haptic feedback should be here
        }) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.white.opacity(0.5) : Color.white.opacity(0.15))
                    .frame(width: 75, height: 75)
                
                VStack(spacing: 0) {
                    Text(number)
                        .font(.system(size: 32, weight: .regular))
                    if !subtext.isEmpty {
                        Text(subtext)
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                    }
                }
                .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        // Visual simulation of press for auto-entry
    }
}
