import SwiftUI

struct ColorPalette {
    let background: Color
    let surface: Color
    let surfaceHover: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let accent: Color
    let accentLight: Color
    let pastDay: Color
    let todayHighlight: Color
    let futureDay: Color
    let futureDayStroke: Color
    let destructive: Color
    let success: Color
}

extension ColorPalette {
    static let earth: ColorPalette = {
        let bg = Color(hex: 0xFAF8F5)
        let sf = Color(hex: 0xF3F0EB)
        let sfh = Color(hex: 0xEBE7E0)
        let tp = Color(hex: 0x2D2A26)
        let ts = Color(hex: 0x7A756D)
        let tt = Color(hex: 0xA9A49B)
        let ac = Color(hex: 0x8B7355)
        let acl = Color(hex: 0xC4AD8C)
        let pd = Color(hex: 0xC4BFB8)
        let th = Color(hex: 0x8B7355)
        let fd = Color(hex: 0xE8E4DE)
        let fds = Color(hex: 0xD9D4CC)
        let des = Color(hex: 0xB85450)
        let suc = Color(hex: 0x6B8E6B)
        return ColorPalette(
            background: bg, surface: sf, surfaceHover: sfh,
            textPrimary: tp, textSecondary: ts, textTertiary: tt,
            accent: ac, accentLight: acl,
            pastDay: pd, todayHighlight: th, futureDay: fd, futureDayStroke: fds,
            destructive: des, success: suc
        )
    }()

    static let slate: ColorPalette = {
        let bg = Color(hex: 0xF4F5F7)
        let sf = Color(hex: 0xECEEF1)
        let sfh = Color(hex: 0xE3E5E9)
        let tp = Color(hex: 0x3F5668)
        let ts = Color(hex: 0x6E8393)
        let tt = Color(hex: 0x9AACB8)
        let ac = Color(hex: 0x6B8CA3)
        let acl = Color(hex: 0xA3BFD0)
        let pd = Color(hex: 0xB0BAC2)
        let th = Color(hex: 0x6B8CA3)
        let fd = Color(hex: 0xE2E6EB)
        let fds = Color(hex: 0xD0D5DC)
        let des = Color(hex: 0xB85450)
        let suc = Color(hex: 0x6B8E6B)
        return ColorPalette(
            background: bg, surface: sf, surfaceHover: sfh,
            textPrimary: tp, textSecondary: ts, textTertiary: tt,
            accent: ac, accentLight: acl,
            pastDay: pd, todayHighlight: th, futureDay: fd, futureDayStroke: fds,
            destructive: des, success: suc
        )
    }()
}
