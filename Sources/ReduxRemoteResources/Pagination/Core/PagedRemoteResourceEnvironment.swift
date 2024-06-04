import ComposableArchitecture
import RemoteResources

public struct PagedRemoteResourceEnvironment<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter
> {
    public typealias LoadPageClosure = (_ pagePath: PagePath, _ filter: Filter?) async throws -> Page<Element, PagePath>

    internal(set) public var firstPage: () throws -> PagePath
    internal(set) public var loadPage: LoadPageClosure
    
    public init(
        firstPage: (() throws -> PagePath)? = nil,
        loadPage: LoadPageClosure? = nil
    ) {
        self.firstPage = firstPage ?? {
            throw AnyDebugError("'\(Self.self).firstPage' is not assigned.")
        }
        self.loadPage = loadPage ?? { _, _ in
            throw AnyDebugError("'\(Self.self).loadPage' is not assigned.")
        }
    }
}

extension PagedRemoteResourceEnvironment: DependencyKey {
    public static var liveValue: Self {
        Self()
    }
}
