import ComposableArchitecture
import RemoteResources

public struct PagedRemoteResourceEnvironment<
    Element: Identifiable,
    PagePath: PagePathType
> {
    public typealias LoadPageClosure = (_ pagePath: PagePath) async throws -> Page<Element, PagePath>

    internal(set) public var firstPage: () throws -> PagePath
    internal(set) public var loadPage: LoadPageClosure
    
    #warning("TODO: Rework with a macro")
    public init(
        firstPage: (() throws -> PagePath)? = nil,
        loadPage: LoadPageClosure? = nil
    ) {
        self.firstPage = firstPage ?? {
            throw AnyDebugError("'\(Self.self).firstPage' is not assigned.")
        }
        self.loadPage = loadPage ?? { _ in
            throw AnyDebugError("'\(Self.self).loadPage' is not assigned.")
        }
    }
}

extension PagedRemoteResourceEnvironment: DependencyKey {
    public static var liveValue: Self {
        Self()
    }
}
