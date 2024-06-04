import ComposableArchitecture
import RemoteResources

@ObservableState
public struct PagedRemoteResourceState<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: Equatable
> {
    public typealias Content = PagedContentState<Element, PagePath>
    
    internal(set) public var content: Content
    internal(set) public var pendingReload: Bool
    internal(set) public var filter: Filter?
    
    public init(
        content: Content = .none,
        pendingReload: Bool = false,
        filter: Filter? = nil
    ) {
        self.content = content
        self.pendingReload = pendingReload
        self.filter = filter
    }
}

extension PagedRemoteResourceState: Equatable where Element: Equatable { }

#warning("TODO: Rework with a macro")
extension PagedContentState: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .none: return "none"
        case .loadingFirst: return "loadingFirst"
        case .partial: return "partial"
        case .complete: return "complete"
        case .failure: return "failure"
        }
    }
}
