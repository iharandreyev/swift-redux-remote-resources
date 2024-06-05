import ComposableArchitecture
import RemoteResources

@CasePathable
public enum PagedFilterableRemoteResourceAction<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter
> {
    public typealias ViewAction = PagedFilterableRemoteResourceAction_View<Filter>
    public typealias InternalAction = PagedFilterableRemoteResourceAction_Internal<Element, PagePath>
    
    case view(ViewAction)
    case `internal`(InternalAction)
    case unexpectedFailure(EquatableByDescription<Error>)
}

extension PagedFilterableRemoteResourceAction: Equatable where Element: Equatable { }

@CasePathable
public enum PagedFilterableRemoteResourceAction_View<
    Filter: PagedRemoteResourceFilter
> {
    case reload
    case loadNext
    case applyFilter(Filter)
}

extension PagedFilterableRemoteResourceAction_View: Equatable where Filter: Equatable { }

@CasePathable
public enum PagedFilterableRemoteResourceAction_Internal<
    Element: Identifiable,
    PagePath: PagePathType
> {
    case applyNextPage(Page<Element, PagePath>)
    case failToLoadNextPage(PagePath, EquatableByDescription<Error>)
}

extension PagedFilterableRemoteResourceAction_Internal: Equatable where Element: Equatable { }

extension PagedFilterableRemoteResourceAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case let .view(action): return "view(\(action.shortDescription))"
        case let .`internal`(action): return "internal(\(action.shortDescription))"
        case let .unexpectedFailure(error): return "\(error.wrappedValue)"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedFilterableRemoteResourceAction_View: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .reload: return "reload"
        case .loadNext: return "loadNext"
        case .applyFilter: return "applyFilter"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedFilterableRemoteResourceAction_Internal: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .applyNextPage: return "applyNextPage"
        case .failToLoadNextPage: return "failToLoadNextPage"
        }
    }
}
