import ReduxRemoteResources
import RemoteResources

extension PagedRemoteResourceState where Element == TestElement, PagePath == TestPagePath {
    @inline(__always)
    init(
        pages: [Page<TestElement, TestPagePath>],
        filter: Filter = .empty()
    ) throws {
        guard !pages.isEmpty else {
            self.init(filter: filter)
            return
        }
        
        let pages = try Pages(pages: pages)

        guard let nextPagePath = pages.lastPagePath.next() else {
            self.init(content: .complete(pages), filter: filter)
            return
        }
        
        self.init(
            content: .partial(pages, next: .pending(nextPagePath)),
            filter: filter
        )
    }
}
