#if DEBUG

import ComposableArchitecture
import IdentifiedCollections
import RemoteResources

extension Paged.UsingPageIndex {
    typealias DebugRemoteResource = FilteredRemoteResource<Identified<String, String>, String>
}

extension StoreOf<Paged.UsingPageIndex.DebugRemoteResource> {
    static func debug(
        environment: Paged.UsingPageIndex.DebugRemoteResource.Environment
    ) -> StoreOf<Paged.UsingPageIndex.DebugRemoteResource> {
        StoreOf<Paged.UsingPageIndex.DebugRemoteResource>(
            initialState: .init(),
            reducer: Paged.UsingPageIndex.DebugRemoteResource.init,
            withDependencies: { values in
                values[Paged.UsingPageIndex.DebugRemoteResource.Environment.self] = environment
            }
        )
    }
}

extension Paged.UsingPageIndex.DebugRemoteResource.Environment {
    static func debugSucceeding(
        pageSize: UInt = 20,
        total: UInt = 100,
        delay miliseconds: UInt64 = 3000
    ) -> Self {
        Self(
            firstPage: {
                try PageIndexPath(0, size: pageSize, of: total)
            },
            loadPage: { path, filter in
                try await Task.sleep(nanoseconds: miliseconds * 1000)
                return try Page(
                    contents: .debugPageContents(pageIndex: path.page, count: path.pageSize, filter: filter),
                    path: PageIndexPath(path.page, size: path.pageSize, of: total)
                )
            }
        )
    }
    
    static func debugAlwaysFailing(
        with error: Error = SomeDebugError(),
        delay miliseconds: UInt64 = 3000
    ) -> Self {
        Self(
            firstPage: {
                try PageIndexPath(0, size: 1, of: 1)
            },
            loadPage: { path, filter in
                try await Task.sleep(nanoseconds: miliseconds * 1000)
                throw error
            }
        )
    }
    
    static func debugFailingSometimes(
        with error: Error = SomeDebugError(),
        pageSize: UInt = 20,
        total: UInt = 100,
        delay miliseconds: UInt64 = 3000
    ) -> Self {
        let attempt = MutableReference(0)
        
        return Self(
            firstPage: {
                try PageIndexPath(0, size: pageSize, of: total)
            },
            loadPage: { path, filter in
                try await Task.sleep(nanoseconds: miliseconds * 1000)
                
                defer {
                    attempt.value += 1
                }
                
                if attempt.value % 3 == 0 {
                    throw error
                }

                return try Page(
                    contents: .debugPageContents(pageIndex: path.page, count: path.pageSize, filter: filter),
                    path: PageIndexPath(path.page, size: path.pageSize, of: total)
                )
            }
        )
    }
}

struct SomeDebugError: Error { }

private final class MutableReference<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

private extension Array where Element == Identified<String, String> {
    static func debugPageContents(
        pageIndex: UInt,
        count: UInt,
        filter: String?
    ) -> Self {
        let startIndex = pageIndex * count
        let endIndex = startIndex + count
        
        return (startIndex ..< endIndex).map { offset in
            let value = "Element #\(offset)" + (filter.map { " [\($0)]" } ?? "")
            return Identified(value, id: value)
        }
    }
}

#endif
