import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "7C3AED"), Color(hex: "06B6D4")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            Image(systemName: "keyboard.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: Color(hex: "7C3AED").opacity(0.5), radius: 20, y: 8)

                        Text("Vibe Keyboard")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "06B6D4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("The keyboard that reads your vibe\nbefore you finish typing")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.top, 32)

                    // How to enable
                    VStack(alignment: .leading, spacing: 0) {
                        Text("How to Enable")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 14)

                        VStack(spacing: 0) {
                            StepRow(number: "1", icon: "gearshape.fill", title: "Open Settings", desc: "Tap the button below to go to Settings")
                            Divider().padding(.leading, 64)
                            StepRow(number: "2", icon: "keyboard", title: "Keyboards", desc: "Go to General → Keyboard → Keyboards")
                            Divider().padding(.leading, 64)
                            StepRow(number: "3", icon: "plus.circle.fill", title: "Add New Keyboard", desc: "Tap \"Add New Keyboard...\"")
                            Divider().padding(.leading, 64)
                            StepRow(number: "4", icon: "checkmark.circle.fill", title: "Select Vibe Keyboard", desc: "Find and tap \"Vibe Keyboard\"")
                            Divider().padding(.leading, 64)
                            StepRow(number: "5", icon: "wifi", title: "Allow Full Access", desc: "Enable Full Access so GIFs can load")
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }

                    // Open settings button
                    Button(action: openKeyboardSettings) {
                        HStack(spacing: 10) {
                            Image(systemName: "gearshape.fill")
                            Text("Open Keyboard Settings")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7C3AED"), Color(hex: "5B21B6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How Vibe Keyboard Works")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            FeatureCard(icon: "bolt.fill", color: Color(hex: "F59E0B"),
                                        title: "Passive Listening",
                                        desc: "Analyzes your words as you type — zero extra effort needed")
                            FeatureCard(icon: "rectangle.topthird.inset.filled", color: Color(hex: "7C3AED"),
                                        title: "The Vibe Bar",
                                        desc: "A live GIF strip above your keys updates instantly as you type")
                            FeatureCard(icon: "hand.tap.fill", color: Color(hex: "06B6D4"),
                                        title: "One Tap to Send",
                                        desc: "Just tap the GIF that matches your vibe — it's already there")
                            FeatureCard(icon: "globe", color: Color(hex: "10B981"),
                                        title: "Works Everywhere",
                                        desc: "WhatsApp, Instagram, Discord, Messages — any app with text input")
                        }
                        .padding(.horizontal, 16)
                    }

                    Color.clear.frame(height: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    func openKeyboardSettings() {
        if let url = URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let fallback = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(fallback)
            }
        }
    }
}

struct StepRow: View {
    let number: String
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "7C3AED").opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "7C3AED"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct FeatureCard: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

#Preview {
    ContentView()
}
