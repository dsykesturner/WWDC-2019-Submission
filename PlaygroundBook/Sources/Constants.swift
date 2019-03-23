//
//  Constants.swift
//  Book_Sources
//
//  Created by Daniel Sykes-Turner on 20/3/19.
//

import UIKit

public struct AirQuality {
    public static let low: String       = "low"
    public static let medium: String    = "medium"
    public static let high: String      = "high"
}

public struct WaterQuality {
    public static let low: String       = "low"
    public static let medium: String    = "medium"
    public static let high: String      = "high"
}

struct Layers {
    static let sunEmitter: CGFloat      = 0
    static let emitter: CGFloat         = 1
    static let background: CGFloat      = 2
    static let sprite: CGFloat          = 3
}

struct CategoryBitMask {
    static let SeaBin: UInt32           = 0b1 << 0
    static let Rubbish: UInt32          = 0b1 << 1
}

public enum PowerSource: Int {
    case coal
    case solarPower
}
