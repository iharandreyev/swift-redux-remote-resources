import RemoteResources
import SwiftUI

public struct PageLoadingIndicator<LoadingView: View, FailureView: View>: View {
    @Binding
    private var nextPage: AnyNextPageState?
    private let onLoadNext: () -> Void
    private let loadingView: () -> LoadingView
    private let failureView: (Error) -> FailureView
    
    public init(
        nextPage: Binding<AnyNextPageState?>,
        onLoadNext: @escaping () -> Void,
        loadingView: @escaping () -> LoadingView,
        failureView: @escaping (Error) -> FailureView
    ) {
        _nextPage = nextPage
        self.onLoadNext = onLoadNext
        self.loadingView = loadingView
        self.failureView = failureView
    }
    
    public var body: some View {
        switch nextPage {
        case .pending:
            EmptyView().onAppear(perform: onLoadNext)
        case .loading:
            loadingView()
        case let .failed(error):
            failureView(error.wrappedValue).onAppearSkippingFirst(perform: onLoadNext)
        case .none:
            SwiftUI.EmptyView()
        }
    }
}
