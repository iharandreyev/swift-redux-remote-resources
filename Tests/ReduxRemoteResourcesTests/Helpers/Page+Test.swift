import RemoteResources

extension Page<TestElement, TestPagePath> {
    static func test(
        offset: UInt,
        filter: String? = nil,
        total: UInt = 1
    ) throws -> Self {
        return try Self(
            contents: [.test("\(offset)" + (filter.map { " + " + $0 } ?? ""))],
            path: TestPagePath(offset: offset, total: total)
        )
    }
    
    static func test(
        after currentOffset: UInt,
        offset: Int,
        filter: String? = nil,
        total: UInt = 1
    ) throws -> Self {
        let offset = currentOffset + UInt(offset)
        return try .test(offset: offset, filter: filter, total: total)
    }
}

extension Array {
    static func partial(
        count: UInt,
        filter: String? = nil,
        total: UInt
    ) throws -> Self where Element == Page<TestElement, TestPagePath> {
        guard count <= total else {
            throw DebugError("Count \(count) is expected to be in range of \(total), but it is not.")
        }
        let first = try Page.test(offset: 0, filter: filter, total: total)
        return try (1 ..< count).reduce(into: [first]) {
            try $0.append(Page.test(offset: $1, filter: filter, total: total))
        }
    }
    
    static func complete(
        filter: String? = nil,
        total: UInt = 1
    ) throws -> Self where Element == Page<TestElement, TestPagePath> {
        try partial(count: total, filter: filter, total: total)
    }
}
