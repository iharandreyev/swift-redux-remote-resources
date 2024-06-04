import Foundation

public protocol PagedRemoteResourceFilter: Equatable {
    var isEmpty: Bool { get }
    
    static func empty() -> Self
}

public struct EmptyPagedRemoteResourceFilter: PagedRemoteResourceFilter {
    public var isEmpty: Bool { true }
    
    static public func empty() -> EmptyPagedRemoteResourceFilter {
        EmptyPagedRemoteResourceFilter()
    }
}

extension String: PagedRemoteResourceFilter {
    public static func empty() -> String { "" }
}
