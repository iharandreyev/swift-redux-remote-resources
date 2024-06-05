import ComposableArchitecture
import RemoteResources

@ObservableState
public struct PagedRemoteResourceState<
    Element: Identifiable,
    PagePath: PagePathType
> {
    public typealias Content = PagedRemoteResourceStateContent<Element, PagePath>

    internal(set) public var content: Content
    internal(set) public var pendingReload: Bool = false

    public init(
        content: Content = .none
    ) {
        self.content = content
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

extension PagedRemoteResourceStateContent: Equatable where Element: Equatable { }
