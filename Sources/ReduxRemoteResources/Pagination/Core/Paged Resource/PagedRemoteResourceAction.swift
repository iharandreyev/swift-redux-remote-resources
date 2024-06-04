import ComposableArchitecture
import RemoteResources

@CasePathable
public enum PagedRemoteResourceAction<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: Equatable
> {
    public typealias ViewAction = PagedRemoteResourceAction_View<Filter>
    public typealias InternalAction = PagedRemoteResourceAction_Internal<Element, PagePath>
    
    case view(ViewAction)
    case `internal`(InternalAction)
    case unexpectedFailure(EquatableByDescription<Error>)
}

extension PagedRemoteResourceAction: Equatable where Element: Equatable { }

@CasePathable
public enum PagedRemoteResourceAction_View<
    Filter
> {
    case reload
    case loadNext
    case applyFilter(Filter?)
}

extension PagedRemoteResourceAction_View: Equatable where Filter: Equatable { }

@CasePathable
public enum PagedRemoteResourceAction_Internal<
    Element: Identifiable,
    PagePath: PagePathType
> {
    case applyNextPage(Page<Element, PagePath>)
    case failToLoadNextPage(PagePath, EquatableByDescription<Error>)
}

extension PagedRemoteResourceAction_Internal: Equatable where Element: Equatable { }

extension PagedRemoteResourceAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case let .view(action): return "view(\(action.shortDescription))"
        case let .`internal`(action): return "internal(\(action.shortDescription))"
        case let .unexpectedFailure(error): return "\(error.wrappedValue)"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedRemoteResourceAction_View: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .reload: return "reload"
        case .loadNext: return "loadNext"
        case .applyFilter: return "applyFilter"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedRemoteResourceAction_Internal: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .applyNextPage: return "applyNextPage"
        case .failToLoadNextPage: return "failToLoadNextPage"
        }
    }
}
