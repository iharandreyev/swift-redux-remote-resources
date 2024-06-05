import ComposableArchitecture
import Foundation
import RemoteResources
import SwiftUI

public struct PagedRemoteResourceView<
    Element: Identifiable & Equatable,
    PagePath: PagePathType,
    Filter: PagedRemoteResourceFilter,
    PlaceholderView: View,
    PageView: View,
    PageLoadingIndicatorView: View,
    FailureView: View
>: View {
    public typealias ViewState = PagedRemoteResourceState<Element, PagePath, Filter>.Content
    public typealias ViewAction = PagedRemoteResourceAction<Element, PagePath, Filter>.ViewAction
    
    let store: Store<ViewState, ViewAction>
    let placeholderView: () -> PlaceholderView
    let elementView: (_ content: Element) -> PageView
    let pageLoadingIndicatorView: () -> PageLoadingIndicatorView
    let failureView: (Error) -> FailureView
    
    public init(
        store: Store<ViewState, ViewAction>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        pageLoadingIndicatorView: @escaping () -> PageLoadingIndicatorView,
        failureView: @escaping (Error) -> FailureView
    ) {
        self.store = store
        self.placeholderView = placeholderView
        self.elementView = elementView
        self.pageLoadingIndicatorView = pageLoadingIndicatorView
        self.failureView = failureView
    }
                        
    public var body: some View {
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
            loadingView: {
                Color(.black).frame(width: 24, height: 24, alignment: .center)
            },
            failureView: { error in
                Text("\(error)").foregroundColor(.red)
            }
        )
    }
}
