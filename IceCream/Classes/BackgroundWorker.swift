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

    private final class WorkItem: NSObject {
        let block: () -> Void

        init(block: @escaping () -> Void) {
            self.block = block
        }
    }
    
    static let shared = BackgroundWorker()
    
    private let threadLock = NSLock()
    private var thread: Thread?
    
    func start(_ block: @escaping () -> Void) {
        threadLock.lock()
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
            thread?.name = "\(String(describing: self))-\(UUID().uuidString)"
            thread?.start()
        }
        let workerThread = thread
        threadLock.unlock()

        guard let workerThread = workerThread else { return }
        if Thread.current == workerThread {
            block()
            return
        }

        perform(#selector(runBlock(_:)),
                on: workerThread,
                with: WorkItem(block: block),
                waitUntilDone: true,
                modes: [RunLoop.Mode.default.rawValue])
    }
    
    func stop() {
        threadLock.lock()
        defer { threadLock.unlock() }
        thread?.cancel()
    }
    
    @objc private func runBlock(_ workItem: WorkItem) {
        workItem.block()
    }
}
