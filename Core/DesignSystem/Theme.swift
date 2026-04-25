import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }

    // Surfaces
    static let mfSurface = Color(hex: 0xF9F9F7)
    static let mfSurfaceContainerLow = Color(hex: 0xF2F4F2)
    static let mfSurfaceContainer = Color(hex: 0xEBEFEC)
    static let mfSurfaceContainerHigh = Color(hex: 0xE5E9E6)
    static let mfSurfaceContainerHighest = Color(hex: 0xDEE4E0)

    // Brand
    static let mfPrimary = Color(hex: 0x536257)
    static let mfPrimaryDim = Color(hex: 0x47564C)
    static let mfPrimaryContainer = Color(hex: 0xD6E7D9)
    static let mfPrimaryFixedDim = Color(hex: 0xC8D9CB)

    // Text and on-colors
    static let mfOnSurface = Color(hex: 0x2D3432)
    static let mfOnSurfaceVariant = Color(hex: 0x5A605E)
    static let mfOnPrimary = Color(hex: 0xEBFCEE)
    static let mfOnPrimaryContainer = Color(hex: 0x46554B)

    // Outlines
    static let mfOutline = Color(hex: 0x767C79)
    static let mfOutlineVariant = Color(hex: 0xADB3B0)

    // Warm accent for occasional editorial moments.
    static let mfTertiary = Color(hex: 0x675E4C)
    static let mfTertiaryContainer = Color(hex: 0xF4E6CF)
}
