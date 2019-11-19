//
//  LogConfig.swift
//  IceCream
//
//  Created by 蔡越 on 30/01/2018.
//

import Foundation

/// This file is for setting some develop configs for IceCream framework.

public class IceCream {
    
    public static let shared = IceCream()

    public var print: ((_ items: Any..., String, String) -> Void) = { items, separator, terminator in
        #if DEBUG
        var i = items.startIndex
        repeat {
            Swift.print(items[i], separator: separator, terminator: i == (items.endIndex - 1) ? terminator : separator)
            i += 1
        } while i < items.endIndex
        #endif
    }

}

/// If you want to know more,
/// this post would help: https://medium.com/@maxcampolo/swift-conditional-logging-compiler-flags-54692dc86c5f
internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    IceCream.shared.print(items, separator: separator, terminator: terminator)
}
