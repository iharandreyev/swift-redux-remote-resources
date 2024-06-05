import RemoteResources
import SwiftUI

struct PageLoadingIndicator<LoadingView: View, FailureView: View>: View {
    @Binding
    var nextPage: AnyNextPageState?
    let onLoadNext: () -> Void
    let loadingView: () -> LoadingView
    let failureView: (Error) -> FailureView
    
    var body: some View {
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
