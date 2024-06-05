import ComposableArchitecture
import RemoteResources

#warning("TODO: Inject animations for actions")
public struct PagedRemoteResource<
    Element: Identifiable,
    PagePath: PagePathType
>: Reducer {
    public typealias State = PagedRemoteResourceState<Element, PagePath>
    public typealias Action = PagedRemoteResourceAction<Element, PagePath>
    public typealias Environment = PagedRemoteResourceEnvironment<Element, PagePath>
    
    private struct CancellationID: Hashable { }
    
    @Dependency(Self.Environment.self)
    private var environment
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return try reduceViewAction(action, into: &state)
                
            case let .internal(action):
                return try reduceInternalAction(action, into: &state)
                
            case let .unexpectedFailure(error):
                runtimeWarn("\(error)")
                return .none
            }
        } catch: { error in
            Action.unexpectedFailure(.with(error))
        }
        ._printChanges()
    }
    
    private func reduceViewAction(
        _ action: Action.ViewAction,
        into state: inout State
    ) throws -> Effect<Action> {
        switch action {
        case .reload:
            switch state.content.value {
            case .none, .loadingFirst, .failure:
                state.content = .loadingFirst
            case .partial, .complete:
                // Preserve existing content
                break
            }
            
            state.pendingReload = true
            
            return try reload()
            
        case .loadNext:
            guard case let .partial(available, next) = state.content.value else {
                throw InvalidStateForActionWarning(
                    Self.self,
                    action: action,
                    invalidState: state.content.value,
                    validStates: "partial"
                )
            }
            
            state.content = .partial(available, next: .loading(next.path))
            
            return loadPage(at: next.path)
        }
    }
    
    private func reduceInternalAction(
        _ action: Action.InternalAction,
        into state: inout State
    ) throws -> Effect<Action> {
        switch action {
        case let .applyNextPage(page):
            switch state.content.value {
            case .none, .loadingFirst, .complete, .failure:
                state.content = try createPages(withFirstPage: page)
                state.pendingReload = false
                
                return .none

            case let .partial(available, _):
                if page.path.isFirst() {
                    state.content = try createPages(withFirstPage: page)
                } else {
                    state.content = try extendPages(available, with: page)
                }
                
                state.pendingReload = false
                
                return .none
            }
            
        case let .failToLoadNextPage(path, error):
            switch state.content.value {
            case .none, .loadingFirst, .failure:
                state.content = .failure(path, error)
                state.pendingReload = false
                
                return .none
                
            case .complete:
                guard state.pendingReload else {
                    throw InvalidStateForActionWarning(
                        Self.self,
                        action: action,
                        invalidState: state.content.value,
                        validStates: "loadingFirst", "partial"
                    )
                }
                
                state.content = .failure(path, error)
                state.pendingReload = false
                
                return .none
                
            case let .partial(available, _):
                if state.pendingReload {
                    state.content = .failure(path, error)
                    state.pendingReload = false
                    
                } else {
                    state.content = .partial(available, next: .failed(path, error))
                }

                return .none
            }
        }
    }
    
    private func createPages(
        withFirstPage page: Page<Element, PagePath>
    ) throws -> State.Content {
        let pages = try Pages(firstPage: page)
        
        switch page.path.next() {
        case .none:
            return .complete(pages)
            
        case let .some(nextPagePath):
            return .partial(pages, next: .pending(nextPagePath))
        }
    }
    
    private func extendPages(
        _ pages: Pages<Element, PagePath>,
        with page: Page<Element, PagePath>
    ) throws -> State.Content {
        let pages = try pages.appending(page: page)
        
        switch page.path.next() {
        case .none:
            return .complete(pages)
            
        case let .some(nextPagePath):
            return .partial(pages, next: .pending(nextPagePath))
        }
    }
    
    // MARK: - Loading
    
    private func reload() throws -> Effect<Action> {
        try loadPage(at: environment.firstPage())
    }
    
    private func loadPage(at path: PagePath) -> Effect<Action> {
        .run(
            priority: .background,
            operation: { sendAction in
                let page = try await environment.loadPage(path)
                await sendAction(.internal(.applyNextPage(page)))
            },
            catch: { error, sendAction in
                await sendAction(.internal(.failToLoadNextPage(path, .with(error))))
            }
        )
        .cancellable(id: CancellationID(), cancelInFlight: true)
    }
}
