import Foundation

extension PagedFilterableRemoteResourceAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case let .view(action): return "view(\(action.shortDescription))"
        case let .resource(action): return "internal(\(action.shortDescription))"
        case let .unexpectedFailure(error): return "\(error.wrappedValue)"
        }
    }
}

#warning("TODO: Rework with a macro")
extension PagedFilterableRemoteResourceAction.ViewAction: CustomShortStringConvertible {
    public var shortDescription: String {
        switch self {
        case .reload: return "reload"
        case .loadNext: return "loadNext"
        case .applyFilter: return "applyFilter"
        }
    }
}
