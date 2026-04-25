import SwiftUI

enum MFFont {
    case displayLG
    case headlineMD
    case body
    case uiLabel
    case overline
}

extension Font {
    static func mf(_ token: MFFont) -> Font {
        switch token {
        case .displayLG:
            .custom("Newsreader16pt-Italic", size: 56)
        case .headlineMD:
            .custom("Newsreader16pt-Regular", size: 28)
        case .body:
            .custom("Newsreader16pt-Regular", size: 17)
        case .uiLabel:
            .custom("Inter-Medium", size: 13)
        case .overline:
            .custom("Inter-SemiBold", size: 12)
        }
    }
}

extension View {
    func mfTextStyle(_ token: MFFont) -> some View {
        let (lineSpacing, tracking, textCase): (CGFloat, CGFloat, Text.Case?) = {
            switch token {
            case .displayLG:
                (3, 0, nil)
            case .headlineMD:
                (5, 0, nil)
            case .body:
                (10, 0, nil)
            case .uiLabel:
                (3, 0, nil)
            case .overline:
                (3, 0.6, .uppercase)
            }
        }()

        return font(.mf(token))
            .lineSpacing(lineSpacing)
            .tracking(tracking)
            .textCase(textCase)
    }
}
