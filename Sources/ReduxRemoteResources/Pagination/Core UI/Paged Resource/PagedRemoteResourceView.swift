import ComposableArchitecture
import Foundation
import RemoteResources
import SwiftUI

#warning("TODO: - Cover with tests")
public struct PagedRemoteResourceView<
    Element: Identifiable & Equatable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter,
    PlaceholderView: View,
    PageView: View,
    FailureView: View,
    NextPageLoadingIndicatorView: View,
    NextPageLoadingFailureView: View
>: View {
    public typealias ViewState = PagedFilterableRemoteResourceState<Element, PagePath, Filter>.Content
    public typealias ViewAction = PagedFilterableRemoteResourceAction<Element, PagePath, Filter>.ViewAction

    private let placeholderView: () -> PlaceholderView
    private let elementView: (_ content: Element) -> PageView
    private let failureView: (Error) -> FailureView
    private let nextPageLoadingIndicatorView: () -> NextPageLoadingIndicatorView
    private let nextPageLoadingFailureView: (Error) -> NextPageLoadingFailureView
    
    private let store: Store<ViewState, ViewAction>
    
    public init(
        store: Store<ViewState, ViewAction>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingIndicatorView: @escaping () -> NextPageLoadingIndicatorView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.store = store
        self.placeholderView = placeholderView
        self.elementView = elementView
        self.failureView = failureView
        self.nextPageLoadingIndicatorView = nextPageLoadingIndicatorView
        self.nextPageLoadingFailureView = nextPageLoadingFailureView
    }
                        
    public var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        
        WithPerceptionTracking {
            switch store.state.value {
            case .none, .loadingFirst:
                placeholderView()
                
            case let .partial(available, _), let .complete(available):
                availableContent(available)

            case let .failure(_, error):
                failureView(error.wrappedValue)
            }
            
            pageLoadingIndicator()
        }
        .onAppear {
            store.send(.reload, animation: .smooth)
        }
    }
    
    private func availableContent(_ pages: Pages<Element, PagePath>) -> some View {
        ForEach(pages.contents) { page in
            ForEach(page.value) { element in
                elementView(element)
            }
        }
    }
    
    private func pageLoadingIndicator() -> some View {
        PageLoadingIndicator(
            nextPage: Binding.readOnly(store.value[case: \.partial]?.next.eraseToAnyNextPageState()),
            onLoadNext: {
                store.send(.loadNext, animation: .smooth)
            },
            loadingView: nextPageLoadingIndicatorView,
            failureView: nextPageLoadingFailureView
        )
    }
}

@available(iOS 14.0, *)
@available(macOS 14.0, *)
@available(catalyst 14.0, *)
@available(tvOS 14.0, *)
@available(watchOS 7.0, *)
@available(visionOS 1.0, *)
extension PagedRemoteResourceView where NextPageLoadingIndicatorView == ProgressView<SwiftUI.EmptyView, SwiftUI.EmptyView> {
    public init(
        store: Store<ViewState, ViewAction>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.init(
            store: store,
            placeholderView: placeholderView,
            elementView: elementView,
            failureView: failureView,
            nextPageLoadingIndicatorView: {
                NextPageLoadingIndicatorView()
            },
            nextPageLoadingFailureView: nextPageLoadingFailureView
        )
    }
}
