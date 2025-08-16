import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct MoroLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        MoroProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct MoroBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct MoroProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1
    @State private var glowIntensity: Double = 0.3

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        shimmerOffset = 1
                    }
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowIntensity = 0.8
                    }
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color(hex: "#0A0A0A"))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#00D4FF").opacity(0.3),
                                Color(hex: "#0099CC").opacity(0.6),
                                Color(hex: "#00D4FF").opacity(0.3),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "#00D4FF").opacity(0.2), radius: 4, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // Основной прогресс с неоновым градиентом
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#00F0FF"),
                            Color(hex: "#0099FF"),
                            Color(hex: "#0066CC"),
                            Color(hex: "#00F0FF"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .shadow(color: Color(hex: "#00D4FF").opacity(glowIntensity), radius: 8, x: 0, y: 0)
                .shadow(color: Color(hex: "#0099FF").opacity(0.6), radius: 4, x: 0, y: 0)

            // Анимированный блик
            if width > 0 {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.6),
                                Color.clear,
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * 0.3, height: height)
                    .offset(x: shimmerOffset * width * 0.7)
                    .mask(
                        RoundedRectangle(cornerRadius: height / 2)
                            .frame(width: width, height: height)
                    )
            }

            // Дополнительное внутреннее свечение
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear,
                            Color.white.opacity(0.1),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height * 0.4)
                .offset(y: -height * 0.15)
        }
        .animation(.easeInOut(duration: 0.3), value: value)
    }
}

// MARK: - Превью

#Preview("Vertical") {
    MoroLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    MoroLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
