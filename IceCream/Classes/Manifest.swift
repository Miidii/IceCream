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

    /// There are quite a lot `print`s in the IceCream source files.
    /// If you don't want to see them in your console, just set `enableLogging` property to false.
    /// The default value is true.
    public var enableLogging: Bool = true

    public var print = { (items: Any, separator: String, terminator: String) -> Void in
        Swift.print(items, separator: separator, terminator: terminator)
    }
}

/// If you want to know more,
/// this post would help: https://medium.com/@maxcampolo/swift-conditional-logging-compiler-flags-54692dc86c5f
internal func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if (IceCream.shared.enableLogging) {
        #if DEBUG
        var i = items.startIndex
        repeat {
            IceCream.shared.print(items[i], separator, i == (items.endIndex - 1) ? terminator : separator)
            i += 1
        } while i < items.endIndex
        #endif
    }
}
