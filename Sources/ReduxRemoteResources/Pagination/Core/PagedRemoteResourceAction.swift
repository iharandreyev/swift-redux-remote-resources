import ComposableArchitecture
import RemoteResources

@CasePathable
public enum PagedRemoteResourceAction<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: Equatable
> {
    public typealias ViewAction = PagedRemoteResourceViewAction<Filter>
    public typealias InternalAction = PagedRemoteResourceInternalAction<Element, PagePath>
    
    case view(ViewAction)
    case `internal`(InternalAction)
    case unexpectedFailure(EquatableByDescription<Error>)
}

extension PagedRemoteResourceAction: Equatable where Element: Equatable { }

@CasePathable
public enum PagedRemoteResourceViewAction<
    Filter
> {
    case reload
    case loadNext
    case applyFilter(Filter?)
}

extension PagedRemoteResourceViewAction: Equatable where Filter: Equatable { }

@CasePathable
public enum PagedRemoteResourceInternalAction<
    Element: Identifiable,
    PagePath: PagePathType
> {
    case applyNextPage(Page<Element, PagePath>)
    case failToLoadNextPage(PagePath, EquatableByDescription<Error>)
}

extension PagedRemoteResourceInternalAction: Equatable where Element: Equatable { }

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
extension PagedRemoteResourceViewAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .reload: return "reload"
        case .loadNext: return "loadNext"
        case .applyFilter: return "applyFilter"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedRemoteResourceInternalAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .applyNextPage: return "applyNextPage"
        case .failToLoadNextPage: return "failToLoadNextPage"
        }
    }
}
