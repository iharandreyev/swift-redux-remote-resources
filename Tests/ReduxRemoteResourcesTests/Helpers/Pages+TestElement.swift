import RemoteResources

extension Pages<TestElement, TestPagePath> {
    @inline(__always)
    static func partial(
        count: UInt,
        filter: String? = nil,
        total: UInt
    ) throws -> Self {
        let pages = try [Page<TestElement, TestPagePath>].partial(
            count: count,
            filter: filter,
            total: total
        )
        return try Self(pages: pages)
    }
    
    @inline(__always)
    static func complete(
        filter: String? = nil,
        total: UInt = 1
    ) throws -> Self {
        let pages = try [Page<TestElement, TestPagePath>].complete(
            filter: filter,
            total: total
        )
        return try Self(pages: pages)
    }
}

extension Pages {
    @inline(__always)
    func nextPagePath() throws -> PagePath {
        guard let next = lastPagePath.next() else {
            throw DebugError("Expected to have a next page path, but there is none.")
        }
        return next
    }
}
