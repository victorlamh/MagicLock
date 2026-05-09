import SwiftUI

// MARK: - Passcode View (iOS 16+ style, pixel-perfect)

struct PasscodeView: View {
    @ObservedObject var state: AppState
    @State private var shakeOffset: CGFloat = 0
    @State private var wrongCode = false

    var body: some View {
        ZStack {
            // — Blurred wallpaper background —
            passcodeBackground
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {

                Spacer().frame(height: 80)

                // — Lock icon or FaceID icon —
                Image(systemName: "lock.fill")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)

                // — Title —
                Text("Enter Passcode")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.bottom, 28)

                // — Passcode dots —
                HStack(spacing: 26) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(state.enteredDigits.count > index
                                  ? Color.white
                                  : Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1.5)
                            )
                            .frame(width: 14, height: 14)
                    }
                }
                .offset(x: shakeOffset)
                .padding(.bottom, 48)

                // — Number pad —
                VStack(spacing: 14) {
                    // Row 1-2-3
                    HStack(spacing: 26) {
                        PasscodeKey(number: 1, letters: "", action: digitTap)
                        PasscodeKey(number: 2, letters: "A B C", action: digitTap)
                        PasscodeKey(number: 3, letters: "D E F", action: digitTap)
                    }
                    // Row 4-5-6
                    HStack(spacing: 26) {
                        PasscodeKey(number: 4, letters: "G H I", action: digitTap)
                        PasscodeKey(number: 5, letters: "J K L", action: digitTap)
                        PasscodeKey(number: 6, letters: "M N O", action: digitTap)
                    }
                    // Row 7-8-9
                    HStack(spacing: 26) {
                        PasscodeKey(number: 7, letters: "P Q R S", action: digitTap)
                        PasscodeKey(number: 8, letters: "T U V", action: digitTap)
                        PasscodeKey(number: 9, letters: "W X Y Z", action: digitTap)
                    }
                    // Row _-0-_
                    HStack(spacing: 26) {
                        // Emergency placeholder (invisible, just for spacing)
                        Color.clear
                            .frame(width: 80, height: 80)

                        PasscodeKey(number: 0, letters: "", action: digitTap)

                        // Delete button
                        Button(action: {
                            if !state.enteredDigits.isEmpty {
                                state.enteredDigits.removeLast()
                            }
                        }) {
                            Image(systemName: "delete.backward")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                        }
                    }
                }

                Spacer()

                // — Bottom buttons —
                HStack {
                    Button(action: {}) {
                        Text("Emergency")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            state.screenState = .locked
                            state.enteredDigits = []
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 60)
            }
        }
    }

    // MARK: — Helpers

    private func digitTap(_ digit: Int) {
        state.enterDigit(digit)
    }

    // MARK: — Background

    private var passcodeBackground: some View {
        ZStack {
            Color.black
            // Blurred abstract background
            Canvas { context, size in
                let topCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.18)
                context.drawLayer { ctx in
                    let colors = Gradient(colors: [
                        Color(red: 0.55, green: 0.45, blue: 0.60).opacity(0.35),
                        Color(red: 0.20, green: 0.15, blue: 0.35).opacity(0.25),
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
                        Color(red: 0.15, green: 0.35, blue: 0.50).opacity(0.3),
                        Color(red: 0.05, green: 0.15, blue: 0.30).opacity(0.2),
                        Color.clear
                    ])
                    let gradient = ctx.resolveShading(.radialGradient(
                        colors, center: bottomCenter,
                        startRadius: 0, endRadius: size.width * 0.75
                    ))
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: gradient)
                }
            }
            .blur(radius: 60)

            // Dark overlay for readability
            Color.black.opacity(0.45)
        }
    }
}

// MARK: - Passcode Key Button (Native iOS style)

struct PasscodeKey: View {
    let number: Int
    let letters: String
    let action: (Int) -> Void

    @State private var isHighlighted = false

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.08)) {
                isHighlighted = true
            }
            action(number)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.15)) {
                    isHighlighted = false
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(isHighlighted
                          ? Color.white.opacity(0.45)
                          : Color.white.opacity(0.12))
                    .frame(width: 80, height: 80)

                VStack(spacing: 1) {
                    Text("\(number)")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundColor(.white)
                    if !letters.isEmpty {
                        Text(letters)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .kerning(2)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
