import SwiftUI

struct SplitFlapView: View {
    let text: String
    let flapColor: Color
    let textColor: Color
    let fontData: Data
    let fontScale: CGFloat
    let flapScale: CGFloat
    let flapCornerScale: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let characters = Array(text)
            let count = max(characters.count, 1)
            let spacing = max(2, proxy.size.width * 0.01)
            let totalSpacing = spacing * CGFloat(max(count - 1, 0))
            let flapWidth = (proxy.size.width - totalSpacing) / CGFloat(count)
            let flapHeight = min(flapWidth * 0.7 * flapScale, proxy.size.height)

            HStack(spacing: spacing) {
                ForEach(characters.indices, id: \.self) { index in
                    FlapCell(
                        character: characters[index],
                        background: flapColor,
                        textColor: textColor,
                        fontData: fontData,
                        fontScale: fontScale,
                        flapCornerScale: flapCornerScale
                    )
                    .frame(width: flapWidth, height: flapHeight)
                }
            }
            .frame(width: proxy.size.width, height: flapHeight)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }
}

private struct FlapCell: View {
    let character: Character
    let background: Color
    let textColor: Color
    let fontData: Data
    let fontScale: CGFloat
    let flapCornerScale: CGFloat

    @State private var current: Character
    @State private var previous: Character
    @State private var topAngle: Double = 0
    @State private var bottomAngle: Double = 90
    @State private var isFlipping = false

    init(character: Character, background: Color, textColor: Color, fontData: Data, fontScale: CGFloat, flapCornerScale: CGFloat) {
        self.character = character
        self.background = background
        self.textColor = textColor
        self.fontData = fontData
        self.fontScale = fontScale
        self.flapCornerScale = flapCornerScale
        _current = State(initialValue: character)
        _previous = State(initialValue: character)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let halfHeight = height / 2
            let cornerRadius = max(2, height * 0.18 * flapCornerScale)
            let fontSize = min(width * 0.85, height * 1.1) * fontScale

            ZStack {
                FlapHalf(
                    character: current,
                    isTop: true,
                    width: width,
                    halfHeight: halfHeight,
                    cornerRadius: cornerRadius,
                    background: background,
                    textColor: textColor,
                    font: FontArchive.font(from: fontData, size: fontSize)
                )
                .frame(width: width, height: halfHeight, alignment: .top)
                .position(x: width / 2, y: halfHeight / 2)

                FlapHalf(
                    character: current,
                    isTop: false,
                    width: width,
                    halfHeight: halfHeight,
                    cornerRadius: cornerRadius,
                    background: background,
                    textColor: textColor,
                    font: FontArchive.font(from: fontData, size: fontSize)
                )
                .frame(width: width, height: halfHeight, alignment: .bottom)
                .position(x: width / 2, y: height - halfHeight / 2)

                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 1)
                    .position(x: width / 2, y: halfHeight)

                FlapHalf(
                    character: previous,
                    isTop: true,
                    width: width,
                    halfHeight: halfHeight,
                    cornerRadius: cornerRadius,
                    background: background,
                    textColor: textColor,
                    font: FontArchive.font(from: fontData, size: fontSize)
                )
                .rotation3DEffect(
                    .degrees(topAngle),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    anchor: .bottom,
                    perspective: 0.55
                )
                .shadow(color: .black.opacity(isFlipping ? 0.25 : 0.0), radius: 4, x: 0, y: 2)
                .opacity(isFlipping ? 1.0 : 0.0)
                .frame(width: width, height: halfHeight, alignment: .top)
                .position(x: width / 2, y: halfHeight / 2)
                .compositingGroup()
                .clipShape(RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight]))
                .zIndex(2)

                FlapHalf(
                    character: current,
                    isTop: false,
                    width: width,
                    halfHeight: halfHeight,
                    cornerRadius: cornerRadius,
                    background: background,
                    textColor: textColor,
                    font: FontArchive.font(from: fontData, size: fontSize)
                )
                .rotation3DEffect(
                    .degrees(bottomAngle),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    anchor: .top,
                    perspective: 0.55
                )
                .shadow(color: .black.opacity(isFlipping ? 0.22 : 0.0), radius: 4, x: 0, y: 3)
                .opacity(isFlipping ? 1.0 : 0.0)
                .frame(width: width, height: halfHeight, alignment: .bottom)
                .position(x: width / 2, y: height - halfHeight / 2)
                .compositingGroup()
                .clipShape(RoundedCorner(radius: cornerRadius, corners: [.bottomLeft, .bottomRight]))
                .zIndex(1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.22), lineWidth: 0.5)
            )
        }
        .clipped()
        .onChange(of: character) { newValue in
            guard newValue != current else {
                return
            }
            previous = current
            isFlipping = true
            topAngle = 0
            bottomAngle = 90

            withAnimation(.easeIn(duration: 0.18)) {
                topAngle = -90
            } completion: {
                current = newValue
                withAnimation(.easeOut(duration: 0.18)) {
                    bottomAngle = 0
                } completion: {
                    isFlipping = false
                    topAngle = 0
                    bottomAngle = 90
                }
            }
        }
    }
}

private struct FlapHalf: View {
    let character: Character
    let isTop: Bool
    let width: CGFloat
    let halfHeight: CGFloat
    let cornerRadius: CGFloat
    let background: Color
    let textColor: Color
    let font: Font

    var body: some View {
        ZStack {
            FlapSurface(background: background, isTop: isTop)

            Text(String(character))
                .font(font)
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .frame(width: width, height: halfHeight * 2)
                .frame(width: width, height: halfHeight, alignment: isTop ? .top : .bottom)
                .clipped()
        }
        .frame(width: width, height: halfHeight)
        .clipShape(RoundedCorner(radius: cornerRadius, corners: isTop ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]))
    }
}

private struct FlapSurface: View {
    let background: Color
    let isTop: Bool

    var body: some View {
        background
            .overlay(
                LinearGradient(
                    colors: isTop
                        ? [Color.white.opacity(0.18), Color.black.opacity(0.06)]
                        : [Color.black.opacity(0.2), Color.white.opacity(0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

private struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
