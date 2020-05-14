//
//  BackgroundWorker.swift
//  IceCream
//
//  Created by Kit Forge on 5/9/19.
//

import Foundation
import RealmSwift

// Based on https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
// Tweaked a little by Yue Cai

class BackgroundWorker: NSObject {
    
    static let shared = BackgroundWorker()

    private var thread: Thread?

    private var queue: DispatchQueue?
    private var queueKey: DispatchSpecificKey<String>?

    private var _block: (() -> Void)?
    private var block: (() -> Void)? {
        get {
            return sync {
                return _block
            }
        }
        set {
            sync {
                _block = newValue
            }
        }
    }
    
    func start(_ block: @escaping () -> Void) {
        self.block = block
        
        if thread == nil {
            thread = Thread { [weak self] in
                guard let self = self, let th = self.thread else {
                    Thread.exit()
                    return
                }
                while (!th.isCancelled) {
                    RunLoop.current.run(
                        mode: .default,
                        before: Date.distantFuture)
                }
                Thread.exit()
            }

            let name = "\(String(describing: self))-\(UUID().uuidString)"

            thread?.name = name
            thread?.start()

            let queue = DispatchQueue(label: name)
            let key = DispatchSpecificKey<String>()

            queue.setSpecific(key: key, value: queue.label)

            self.queue = queue
            self.queueKey = key
        }
        
        if let thread = thread {
            perform(#selector(runBlock),
                    on: thread,
                    with: nil,
                    waitUntilDone: true,
                    modes: [RunLoop.Mode.default.rawValue])
        }
    }
    
    func stop() {
        thread?.cancel()
    }
    
    @objc private func runBlock() {
        block?()
    }

    // https://gist.github.com/khanlou/2dc012e356fd372ecba845752d9a938a
    private func sync<T>(_ execute: () -> T) -> T {
        guard let key = queueKey, let queue = queue else {
            return execute()
        }

        if DispatchQueue.getSpecific(key: key) == queue.label {
            return execute()
        } else {
            return queue.sync {
                return execute()
            }
        }
    }
}
