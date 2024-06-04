import ComposableArchitecture
import RemoteResources

@ObservableState
public struct PagedRemoteResourceState<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter
> {
    public typealias Element = Element
    public typealias PagePath = PagePath
    public typealias Content = PagedRemoteResourceStateContent<Element, PagePath>
    public typealias Filter = Filter

    internal(set) public var content: Content
    internal(set) public var pendingReload: Bool
    internal(set) public var filter: Filter

    public init(
        content: Content = .none,
        pendingReload: Bool = false,
        filter: Filter = .empty()
    ) {
        self.content = content
        self.pendingReload = pendingReload
        self.filter = filter
    }
}

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

extension PagedRemoteResourceState: Equatable where Element: Equatable { }

@ObservableState
public struct PagedRemoteResourceStateContent<
    Element: Identifiable,
    PagePath: PagePathType
>: PagedContentStateWrapper {
    internal(set) public var value: PagedContentState<Element, PagePath>
    
    public init(_ value: PagedContentState<Element, PagePath>) {
        self.value = value
    }
}

extension PagedRemoteResourceStateContent {
    var canAppendNext: Bool {
        switch value {
        case .none, .loadingFirst, .partial: return true
        case .complete, .failure: return false
        }
    }
}

extension PagedRemoteResourceStateContent: Equatable where Element: Equatable { }
