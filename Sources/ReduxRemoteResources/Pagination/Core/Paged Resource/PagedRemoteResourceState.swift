import ComposableArchitecture
import RemoteResources

@ObservableState
public struct PagedRemoteResourceState<
    Element: Identifiable,
    PagePath: PagePathType
> {
    public typealias Element = Element
    public typealias PagePath = PagePath
    public typealias Content = PagedRemoteResourceStateContent<Element, PagePath>

    internal(set) public var content: Content
    internal(set) public var pendingReload: Bool

    public init(
        content: Content = .none,
        pendingReload: Bool = false
    ) {
        self.content = content
        self.pendingReload = pendingReload
    }
}

extension PagedRemoteResourceState: Equatable where Element: Equatable { }
