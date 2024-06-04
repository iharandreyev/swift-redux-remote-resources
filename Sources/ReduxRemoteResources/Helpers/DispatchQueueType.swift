import Foundation

public protocol DispatchQueueType {
    func async(execute workItem: DispatchWorkItem)
    func asyncAfter(delay: TimeInterval, execute workItem: DispatchWorkItem)
}

extension DispatchQueueType {
    @inline(__always)
    func async(execute workItem: DispatchWorkItem) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            workItem.notify(queue: .main) {
                continuation.resume()
            }
            async(execute: workItem)
        }
    }
    
    @inline(__always)
    public func async(
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute block: @escaping @Sendable () -> Void
    ) {
        async(execute: DispatchWorkItem(qos: qos, flags: flags, block: block))
    }

    @inline(__always)
    public func async(
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute block: @escaping @Sendable () -> Void
    ) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            let workItem = DispatchWorkItem(qos: qos, flags: flags, block: block)
            workItem.notify(queue: .main) {
                continuation.resume()
            }
            async(execute: workItem)
        }
    }
    
    @inline(__always)
    func asyncAfter(delay: TimeInterval, execute workItem: DispatchWorkItem) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            workItem.notify(queue: .main) {
                continuation.resume()
            }
            asyncAfter(delay: delay, execute: workItem)
        }
    }
    
    @inline(__always)
    public func asyncAfter(
        delay: TimeInterval,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute block: @escaping () -> Void
    ) {
        asyncAfter(delay: delay, execute: DispatchWorkItem(qos: qos, flags: flags, block: block))
    }
    
    @inline(__always)
    public func asyncAfter(
        delay: TimeInterval,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute block: @escaping () -> Void
    ) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            let workItem = DispatchWorkItem(qos: qos, flags: flags, block: block)
            workItem.notify(queue: .main) {
                continuation.resume()
            }
            asyncAfter(delay: delay, execute: workItem)
        }
    }
    
    @inline(__always)
    func sleep(for delay: TimeInterval) async {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            let workItem = DispatchWorkItem { }
            workItem.notify(queue: .main) {
                continuation.resume()
            }
            asyncAfter(delay: delay, execute: workItem)
        }
    }
}

extension DispatchQueue: DispatchQueueType {
    @inline(__always)
    public func asyncAfter(delay: TimeInterval, execute workItem: DispatchWorkItem) {
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
