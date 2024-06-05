import RemoteResources

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
