import RemoteResources

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
