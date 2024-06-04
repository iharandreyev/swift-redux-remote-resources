import ComposableArchitecture
import Foundation
import RemoteResources
import SwiftUI

public struct PagedRemoteResourceView<
    Element: Identifiable & Equatable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter,
    PlaceholderView: View,
    LoadingFirstView: View,
    PageView: View,
    PageLoadingIndicatorView: View,
    FailureView: View
>: View {
    public typealias ViewState = PagedRemoteResourceState<Element, PagePath, Filter>.Content
    public typealias ViewAction = PagedRemoteResourceAction<Element, PagePath, Filter>.ViewAction
    
    let store: Store<ViewState, ViewAction>
    let placeholderView: () -> PlaceholderView
    let loadingFirstView: () -> LoadingFirstView
    let elementView: (_ content: Element) -> PageView
    let pageLoadingIndicatorView: () -> PageLoadingIndicatorView
    let failureView: (Error) -> FailureView
    
    public init(
        store: Store<ViewState, ViewAction>,
        placeholderView: @escaping () -> PlaceholderView,
        loadingFirstView: @escaping () -> LoadingFirstView,
        elementView: @escaping (_ content: Element) -> PageView,
        pageLoadingIndicatorView: @escaping () -> PageLoadingIndicatorView,
        failureView: @escaping (Error) -> FailureView
    ) {
        self.store = store
        self.placeholderView = placeholderView
        self.loadingFirstView = loadingFirstView
        self.elementView = elementView
        self.pageLoadingIndicatorView = pageLoadingIndicatorView
        self.failureView = failureView
    }
                        
    public var body: some View {
        WithPerceptionTracking {
            switch store.state.value {
            case PagedContentState<Element, PagePath>.none:
                placeholderView()
                
            case PagedContentState<Element, PagePath>.loadingFirst:
                loadingFirstView()
                
            case let PagedContentState<Element, PagePath>.partial(available, next):
                partialContent(available, next: next.eraseToAnyNextPageState())
                
            case let PagedContentState<Element, PagePath>.complete(pages):
                availableContent(pages)
                
            case let PagedContentState<Element, PagePath>.failure(_, error):
                failureView(error.wrappedValue)
            }
        }
        .onAppear {
            store.send(.reload, animation: .smooth)
        }
    }

    @ViewBuilder
    private func partialContent(
        _ available: Pages<Element, PagePath>,
        next: AnyNextPageState
    ) -> some View {
        availableContent(available)
        
        PageLoadingIndicator(
            nextPage: next,
            onLoadNext: {
                store.send(.loadNext, animation: .smooth)
            },
            loadingView: {
                Color(.black).frame(width: 24, height: 24, alignment: .center)
            },
            failureView: { error in
                Text("\(error)").foregroundColor(.red)
            }
        )
    }
    
    private func availableContent(_ pages: Pages<Element, PagePath>) -> some View {
        ForEach(pages.contents) { page in
            ForEach(page.value) { element in
                elementView(element)
            }
        }
    }
}
