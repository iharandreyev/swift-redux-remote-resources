import ComposableArchitecture
import RemoteResources

public struct PagedRemoteResource<
    Element: Identifiable & Equatable,
    PagePath: PagePathType,
    Filter: Equatable
>: Reducer {
    public typealias State = PagedRemoteResourceState<Element, PagePath, Filter>
    public typealias Action = PagedRemoteResourceAction<Element, PagePath, Filter>
    public typealias Environment = PagedRemoteResourceEnvironment<Element, PagePath, Filter>
    
    private struct CancellationID: Hashable { }
    
    @Dependency(Self.Environment.self)
    private var environment
    
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
    }
    
    private func reduceViewAction(
        _ action: Action.ViewAction,
        into state: inout State
    ) throws -> Effect<Action> {
        switch action {
        case .reload:
            switch state.content {
            case .none, .loadingFirst, .failure:
                state.content = .loadingFirst
            case .partial, .complete:
                // Preserve existing content
                break
            }
            
            state.pendingReload = true
            
            return try reload(with: state.filter)
            
        case .loadNext:
            guard case let .partial(available, next) = state.content else {
                throw InvalidStateForActionWarning(
                    Self.self,
                    action: action,
                    invalidState: state.content,
                    validStates: "partial"
                )
            }
            
            state.content = .partial(available, next: .loading(next.path))
            
            return loadPage(at: next.path, filter: state.filter)
            
        case let .applyFilter(newValue):
            guard newValue != state.filter else { return .none }
            
            state.pendingReload = true
            state.filter = newValue
            
            return try reload(with: newValue)
        }
    }
    
    private func reduceInternalAction(
        _ action: Action.InternalAction,
        into state: inout State
    ) throws -> Effect<Action> {
        switch action {
        case let .applyNextPage(page):
            switch state.content {
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
            switch state.content {
            case .none, .loadingFirst, .failure:
                state.content = .failure(path, error)
                state.pendingReload = false
                
                return .none
                
            case .complete:
                guard state.pendingReload else {
                    throw InvalidStateForActionWarning(
                        Self.self,
                        action: action,
                        invalidState: state.content,
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
    
    private func reload(with filter: Filter?) throws -> Effect<Action> {
        try loadPage(at: environment.firstPage(), filter: filter)
    }
    
    private func loadPage(at path: PagePath, filter: Filter?) -> Effect<Action> {
        .run(
            priority: .background,
            operation: { sendAction in
                let page = try await environment.loadPage(path, filter)
                await sendAction(.internal(.applyNextPage(page)))
            },
            catch: { error, sendAction in
                await sendAction(.internal(.failToLoadNextPage(path, .with(error))))
            }
        )
        .cancellable(id: CancellationID(), cancelInFlight: true)
    }
}
