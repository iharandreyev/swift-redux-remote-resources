@testable import ReduxRemoteResources
import ComposableArchitecture
import RemoteResources
import XCTest

final class PagedRemoteResourceTests: XCTestCase {
    // MARK: - Reload
    
    @MainActor
    func testReloadSuccessWhenStateIsEmpty() async throws {
        let environment = SUT.Environment.succeeding()
        let store = TestStoreOf<SUT>.create(environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.content = .loadingFirst
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .complete()
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testReloadSuccessWhenStateIsPartial() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, total: totalPages)
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testReloadSuccessWhenStateIsComplete() async throws {
        let totalPages: UInt = 3
        let state = try SUT.State(
            content: .complete(total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, total: totalPages)
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testReloadFailureWhenStateIsEmpty() async throws {
        let error = AnyDebugError("test_error")
        let environment = SUT.Environment.failing(with: error)
        let store = TestStoreOf<SUT>.create(environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.content = .loadingFirst
            state.pendingReload = true
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.content = .failure(.first(), .with(error))
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testReloadFailureWhenStateIsPartial() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let error = AnyDebugError("test_error")
        let environment = SUT.Environment.failing(with: error)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.pendingReload = true
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.content = .failure(.first(), .with(error))
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testReloadFailureWhenStateIsComplete() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .complete(total: totalPages)
        )
        let error = AnyDebugError("test_error")
        let environment = SUT.Environment.failing(with: error)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.pendingReload = true
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.content = .failure(.first(), .with(error))
            state.pendingReload = false
        }
    }
    
    // MARK: - Load Next
    
    @MainActor
    func testLoadNextSuccessWhenNextPageIsNotTheLastOne() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: 2, total: totalPages)
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 3, total: totalPages)
        }
    }
    
    @MainActor
    func testLoadNextSuccessWhenNextPageIsTheLastOne() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .partialPending(count: totalPages - 1, total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: totalPages - 1, total: totalPages)
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .complete(total: totalPages)
        }
    }
    
    @MainActor
    func testLoadNextFailureWhenNextPageIsNotTheLastOne() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let error = AnyDebugError("test_error")
        let environment = SUT.Environment.failing(with: error)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: 2, total: totalPages)
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.content = try .partialFailed(count: 2, total: totalPages, error: error)
        }
    }
    
    @MainActor
    func testLoadNextPageImpossibleWhenStateIsComplete() async throws {
        let totalPages: UInt = 5
        let state = try SUT.State(
            content: .complete(total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.loadNext))
        await store.receive(\.unexpectedFailure)
    }
    
    // MARK: - Filter
    
    @MainActor
    func testSuccessOnApplyFilterInvokesReload() async throws {
        let totalPages: UInt = 5
        let filter = "test_filter"
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.applyFilter(filter))) { state in
            state.filter = filter
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, filter: filter, total: totalPages)
            state.pendingReload = false
        }
    }
    
    @MainActor
    func testApplyTheSameFilterDoesNothing() async throws {
        let filter = "test_filter"
        let state = try SUT.State(
            content: .complete(),
            filter: filter
        )
        let environment = SUT.Environment.succeeding()
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.applyFilter(filter)))
    }
    
    @MainActor
    func testFailureOnApplyFilterInvokesReload() async throws {
        let totalPages: UInt = 5
        let filter = "test_filter"
        let state = try SUT.State(
            content: .partialPending(count: 2, total: totalPages)
        )
        let error = AnyDebugError("test_error")
        let environment = SUT.Environment.failing(with: error)
        let store = TestStoreOf<SUT>.create(with: state, environment: environment)
        
        await store.send(.view(.applyFilter(filter))) { state in
            state.filter = filter
            state.pendingReload = true
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.filter = filter
            state.content = .failure(.first(), .with(error))
            state.pendingReload = false
        }
    }
    
    // MARK: - Cancellation
    
    @MainActor
    func testLoadCancellsExistingEffects() async throws {
        let queue = TestDispatchQueue()
        let environment = SUT.Environment.succeeding(delayedOn: queue)
        let store = TestStoreOf<SUT>.create(environment: environment)
        
        await store.send(.view(.reload))  { state in
            state.content = .loadingFirst
            state.pendingReload = true
        }
        await store.send(.view(.reload))
        await store.send(.view(.reload))
        
        queue.advance(by: 1)
        
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .complete(Pages(firstPage: .test(offset: 0)))
            state.pendingReload = false
        }
    }
    
    // MARK: - Scenarios
    
    @MainActor
    func testScenario() async throws {
        let totalPages: UInt = 5
        let error = DebugError("test_error")
        let filter = "test_filter"
        let environment = SUT.Environment.succeeding(totalPages: totalPages)
        var store = TestStoreOf<SUT>.create(environment: environment)
        
        await store.send(.view(.reload)) { state in
            state.content = .loadingFirst
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, total: totalPages)
            state.pendingReload = false
        }
    
        store = store.reload(
            with: SUT.Environment.failing(with: error)
        )
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: 1, total: totalPages)
        }
        await store.receive(\.internal.failToLoadNextPage) { state in
            state.content = try .partialFailed(count: 1, total: totalPages, error: error)
        }
        
        store = store.reload(
            with: SUT.Environment.succeeding(totalPages: totalPages)
        )
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: 1, total: totalPages)
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 2, total: totalPages)
        }
        
        await store.send(.view(.applyFilter(filter))) { state in
            state.content = try .partialPending(count: 2, total: totalPages)
            state.filter = filter
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, filter: filter, total: totalPages)
            state.pendingReload = false
        }
        
        await store.send(.view(.loadNext)) { state in
            state.content = try .partialLoading(count: 1, filter: filter, total: totalPages)
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 2, filter: filter, total: totalPages)
        }
        
        await store.send(.view(.applyFilter(.empty()))) { state in
            state.content = try .partialPending(count: 2, filter: filter, total: totalPages)
            state.filter = .empty()
            state.pendingReload = true
        }
        await store.receive(\.internal.applyNextPage) { state in
            state.content = try .partialPending(count: 1, total: totalPages)
            state.pendingReload = false
        }
    }
}

// MARK: - Helpers

private typealias SUT = PagedRemoteResource<TestElement, TestPagePath, String>

private extension TestStoreOf<SUT> {
    @inline(__always)
    static func create(
        with initalState: SUT.State = SUT.State(),
        environment: SUT.Environment,
        file: StaticString = #file,
        line: UInt = #line
    ) -> TestStoreOf<SUT> {
        TestStoreOf<SUT>(
            initialState: initalState,
            reducer: SUT.init,
            withDependencies: {
                $0[SUT.Environment.self] = environment
            },
            file: file,
            line: line
        )
    }
    
    func reload(with environment: SUT.Environment) -> TestStoreOf<SUT> {
        .create(with: state, environment: environment)
    }
}

private extension SUT.Environment {
    @inline(__always)
    static func succeeding(
        totalPages: UInt = 1,
        delayedOn queue: DispatchQueueType = InstantDispatchQueue()
    ) -> Self {
        Self.init(
            loadPage: { path, filter in
                try Page.test(
                    offset: path.offset,
                    filter: filter,
                    total: totalPages
                )
            },
            delayedOn: queue
        )
    }
    
    @inline(__always)
    static func failing(
        with error: Error,
        delayedOn queue: DispatchQueueType = InstantDispatchQueue()
    ) -> Self {
        Self.init(
            loadPage: { path, filter in
                throw error
            },
            delayedOn: queue
        )
    }
    
    @inline(__always)
    private init(
        firstPage: (() throws -> PagePath)? = nil,
        loadPage: @escaping LoadPageClosure,
        delayedOn queue: DispatchQueueType
    ) {
        self.init(
            firstPage: { TestPagePath.first() },
            loadPage: { path, filter in
                await queue.sleep(for: 0.5)
                return try await loadPage(path, filter)
            }
        )
    }
}
