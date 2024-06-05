#if DEBUG

import IdentifiedCollections
import SwiftUI
import ComposableArchitecture
import RemoteResources

@available(iOS 14.0, *)
#Preview {
    PagedRemoteResourceView_Preview_iOS()
}

@available(iOS 14.0, *)
struct PagedRemoteResourceView_Preview_iOS: View {
    typealias ParentFeature = Paged.UsingPageIndex.DebugRemoteResource
    
    typealias ViewState = ParentFeature.State.Content
    typealias ViewAction = ParentFeature.Action.ViewAction
    
    @Perception.Bindable
    private var store: StoreOf<ParentFeature>
    
    init(
        environment: ParentFeature.Environment = .debugFailingSometimes()
    ) {
        store = StoreOf<ParentFeature>.debug(environment: environment)
    }
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 16) {
                    TextField(
                        "Filter",
                        text: $store.filter.sending(\.view.applyFilter).debounced(delay: 1)
                    )
                    
                    PagedRemoteResourceView(
                        store: store,
                        placeholderView: {
                            Color(.cyan).frame(height: 24)
                        },
                        elementView: { element in
                            Text(element.value)
                        },
                        failureView: { error in
                            Text("\(error)").background(Color.red)
                        },
                        nextPageLoadingFailureView: { error in
                            Text("\(error)").foregroundColor(.red)
                        }
                    )
                }
            }
        }
    }
}

#endif
