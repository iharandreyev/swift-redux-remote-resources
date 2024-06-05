import ComposableArchitecture
import RemoteResources

// MARK: - State

@ObservableState
@dynamicMemberLookup
public struct PagedFilterableRemoteResourceState<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter
> {
    public typealias ResourceState = PagedRemoteResourceState<Element, PagePath>
    public typealias Content = ResourceState.Content
    public typealias ObservableContent = ResourceState.ObservableContent
    
    fileprivate var resource: ResourceState
    
    internal(set) public var filter: Filter

    public init(
        content: ResourceState.Content = .none,
        filter: Filter = .empty()
    ) {
        self.resource = PagedRemoteResourceState(content: content)
        self.filter = filter
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<ResourceState, T>) -> T {
        get { resource[keyPath: keyPath] }
        set { resource[keyPath: keyPath] = newValue }
    }
}

// MARK: - Action

@CasePathable
public enum PagedFilterableRemoteResourceAction<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter
> {
    @CasePathable
    public enum ViewAction: Equatable {
        case reload
        case loadNext
        case applyFilter(Filter)
        
        fileprivate init(_ resourceViewAction: ResourceAction.ViewAction) {
            switch resourceViewAction {
            case .reload: self = .reload
            case .loadNext: self = .loadNext
            }
        }
    }
    
    public typealias ResourceAction = PagedRemoteResourceAction<Element, PagePath>

    case view(ViewAction)
    case resource(ResourceAction)
    case unexpectedFailure(EquatableByDescription<Error>)
}

// MARK: - Reducer

#warning("TODO: Inject animations for actions")
public struct PagedFilterableRemoteResource<
    Element: Identifiable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter
>: Reducer {
    public typealias State = PagedFilterableRemoteResourceState<Element, PagePath, Filter>
    public typealias Action = PagedFilterableRemoteResourceAction<Element, PagePath, Filter>
    public typealias Environment = PagedFilterableRemoteResourceEnvironment<Element, PagePath, Filter>
    
    private struct CancellationID: Hashable { }
    private typealias Resource = PagedRemoteResource<Element, PagePath>
    
    @Dependency(Self.Environment.self)
    private var environment
    
    // Child reducer is extracted into a property since we need to totally override some actions
    private let resource = Resource()
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return try reduceViewAction(action, into: &state)
                
            case let .resource(action):
                return try reduceResourceAction(action, into: &state)
                
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
    
    private func reduceResourceAction(
        _ action: Action.ResourceAction,
        into state: inout State
    ) throws -> Effect<Action> {
        switch action {
        case let .view(viewAction):
            return reduce(into: &state, action: .view(.init(viewAction)))
            
        case let .unexpectedFailure(error):
            return reduce(into: &state, action: .unexpectedFailure(error))
            
        case let .internal(action):
            return resource.reduce(
                into: &state.resource,
                action: .internal(action)
            )
            .map(Action.resource)
        }
    }
    
    // MARK: - Loading
    
    private func reload(with filter: Filter) throws -> Effect<Action> {
        try loadPage(at: environment.firstPage(), filter: filter)
    }
    
    private func loadPage(at path: PagePath, filter: Filter) -> Effect<Action> {
        .run(
            priority: .background,
            operation: { sendAction in
                let page = try await environment.loadPage(path, filter)
                await sendAction(.resource(.internal(.applyNextPage(page))))
            },
            catch: { error, sendAction in
                await sendAction(.resource(.internal(.failToLoadNextPage(path, .with(error)))))
            }
        )
        .cancellable(id: CancellationID(), cancelInFlight: true)
    }
}

extension PagedFilterableRemoteResourceState: Equatable where Element: Equatable { }
extension PagedFilterableRemoteResourceAction: Equatable where Element: Equatable { }
