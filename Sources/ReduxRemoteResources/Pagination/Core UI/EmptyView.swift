import SwiftUI

/// Used instead of `SwiftUI.EmptyView` to attach appearance handlers
struct EmptyView: View {
    var body: some View {
        Color(.clear).frame(width: 1, height: 1, alignment: .center)
    }
}
