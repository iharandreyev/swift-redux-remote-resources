import RemoteResources

struct TestPagePath: PagePathType {
    let offset: UInt
    let total: UInt

    init(offset: UInt, total: UInt = 1) {
        self.offset = offset
        self.total = total
    }
    
    static func first(total: UInt = 1) -> Self {
        Self(offset: 0, total: total)
    }
    
    func next() -> Self? {
        guard offset + 1 < total else { return nil }
        return Self(offset: offset + 1, total: total)
    }
    
    func isFirst() -> Bool {
        offset == 0
    }
    
    func isNext(for path: Self) throws -> Bool {
        offset - path.offset == 1
    }
}
