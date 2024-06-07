import ComposableArchitecture
import Foundation
import RemoteResources
import SwiftUI

#warning("TODO: - Cover with tests")
@available(iOS 14.0, *)
public struct PagedRemoteResourceView<
    Element: Identifiable & Equatable,
    PagePath: PagePathType,
    PlaceholderView: View,
    PageView: View,
    FailureView: View,
    NextPageLoadingIndicatorView: View,
    NextPageLoadingFailureView: View
>: View {
    public typealias ViewState = PagedRemoteResourceState<Element, PagePath>.ObservableContent
    public typealias ViewAction = PagedRemoteResourceAction<Element, PagePath>.ViewAction

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
            switch store.wrappedValue {
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
            AnimatedTransitionContainer {
                SectionView(content: page.value, elementView: elementView).id(page.id)
            }
            .background(Color.yellow)
            //            .tag(pages.contents.id)
//            .transition(.scale)
//            SectionView(content: page.value, elementView: elementView).tag(page.id)
        }
    }
    
    private func pageLoadingIndicator() -> some View {
        PageLoadingIndicator(
            nextPage: Binding.readOnly(store.wrappedValue[case: \.partial]?.next.eraseToAnyNextPageState()),
            onLoadNext: {
                store.send(.loadNext, animation: .smooth)
            },
            loadingView: nextPageLoadingIndicatorView,
            failureView: nextPageLoadingFailureView
        )
    }
}

struct SectionView<Element: Identifiable, ElementView: View>: View {
    let content: IdentifiedArray<Element.ID, Element>
    let elementView: (Element) -> ElementView

    var body: some View {
        ForEach(content) { element in
            elementView(element).tag(element.id).transition(.scale)
        }
    }
}

public struct AnimatedTransition {
    public let animation: Animation?
    public let transition: AnyTransition
}

extension AnimatedTransition {
    public init(animation: Animation, transition: AnyTransition) {
        self.animation = animation
        self.transition = transition
    }
    
    public static func none() -> Self {
        .init(animation: nil, transition: .identity)
    }
    
    public static func opacity() -> Self {
        .init(animation: .smooth, transition: .opacity)
    }
}

@available(iOS 14.0, *)
public struct AnimatedTransitionContainer<Content: View>: View {
    private enum ViewState: String, Equatable {
        case initial
        case content
    }
    
    @State
    private var state: ViewState = .initial
    
    private let transition: AnimatedTransition
    private let content: () -> Content
    
    public init(
        transition: AnimatedTransition = .opacity(),
        content: @escaping () -> Content
    ) {
        self.transition = transition
        self.content = content
    }
    
    let id = UUID().uuidString
    
    @Namespace private var animation

    public var body: some View {
        Group {
            switch state {
            case .initial:
                Color(.brown).onAppear {
                    DispatchQueue.main.asyncAfter(delay: 1) {
                        withAnimation(transition.animation) {
                            state = .content
                        }
                    }
                }
//                .tag(id + "_placeholder")
//                .matchedGeometryEffect(id: id, in: animation, properties: .size, isSource: false)
            case .content:
                content().layoutPriority(100)
                    .transition(transition.transition)
                
//                Rectangle().fill(Color.clear).overlay(content().layoutPriority(100))
//                    .tag(id + "_content")
                    
//                    .matchedGeometryEffect(id: id, in: animation, properties: .size, isSource: true)
            }
        }
    }
}

@available(iOS 14.0, *)
@available(macOS 14.0, *)
@available(macCatalyst 14.0, *)
@available(tvOS 14.0, *)
@available(watchOS 7.0, *)
@available(visionOS 1.0, *)
extension PagedRemoteResourceView where NextPageLoadingIndicatorView == ProgressView<SwiftUI.EmptyView, SwiftUI.EmptyView> {
    @inlinable
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
    
    @inlinable
    public init(
        store: StoreOf<PagedRemoteResource<Element, PagePath>>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.init(
            store: store.scope(state: \.__content, action: \.view),
            placeholderView: placeholderView,
            elementView: elementView,
            failureView: failureView,
            nextPageLoadingIndicatorView: {
                NextPageLoadingIndicatorView()
            },
            nextPageLoadingFailureView: nextPageLoadingFailureView
        )
    }
    
    @inlinable
    public init<Filter: PagedRemoteResourceFilter>(
        store: StoreOf<PagedFilterableRemoteResource<Element, PagePath, Filter>>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.init(
            store: store.scope(state: \.__content, action: \.resource.view),
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

@available(iOS 14.0, *)
extension PagedRemoteResourceView {
    @inlinable
    public init(
        store: StoreOf<PagedRemoteResource<Element, PagePath>>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingIndicatorView: @escaping () -> NextPageLoadingIndicatorView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.init(
            store: store.scope(state: \.__content, action: \.view),
            placeholderView: placeholderView,
            elementView: elementView,
            failureView: failureView,
            nextPageLoadingIndicatorView: nextPageLoadingIndicatorView,
            nextPageLoadingFailureView: nextPageLoadingFailureView
        )
    }
    
    @inlinable
    public init<Filter: PagedRemoteResourceFilter>(
        store: StoreOf<PagedFilterableRemoteResource<Element, PagePath, Filter>>,
        placeholderView: @escaping () -> PlaceholderView,
        elementView: @escaping (_ content: Element) -> PageView,
        failureView: @escaping (Error) -> FailureView,
        nextPageLoadingIndicatorView: @escaping () -> NextPageLoadingIndicatorView,
        nextPageLoadingFailureView: @escaping (Error) -> NextPageLoadingFailureView
    ) {
        self.init(
            store: store.scope(state: \.__content, action: \.resource.view),
            placeholderView: placeholderView,
            elementView: elementView,
            failureView: failureView,
            nextPageLoadingIndicatorView: nextPageLoadingIndicatorView,
            nextPageLoadingFailureView: nextPageLoadingFailureView
        )
    }
}
