import ReduxRemoteResources
import RemoteResources

extension PagedFilterableRemoteResourceStateContent where Element == TestElement, PagePath == TestPagePath {
    @inline(__always)
    static func partialPending(
        count: UInt,
        filter: String = .empty(),
        total: UInt
    ) throws -> Self {
        let available = try Pages.partial(count: count, filter: filter, total: total)
        return try Self.partial(available, next: .pending(available.nextPagePath()))
    }
    
    @inline(__always)
    static func partialLoading(
        count: UInt,
        filter: String = .empty(),
        total: UInt
    ) throws -> Self {
        let available = try Pages.partial(count: count, filter: filter, total: total)
        return try Self.partial(available, next: .loading(available.nextPagePath()))
    }
    
    @inline(__always)
    static func partialFailed(
        count: UInt,
        filter: String = .empty(),
        total: UInt,
        error: Error
    ) throws -> Self {
        let available = try Pages.partial(count: count, filter: filter, total: total)
        return try Self.partial(available, next: .failed(available.nextPagePath(), error))
    }
    
    @inline(__always)
    static func complete(
        filter: String = .empty(),
        total: UInt = 1
    ) throws -> Self {
        let available = try Pages.complete(filter: filter, total: total)
        return Self.complete(available)
    }
}
