import SwiftUI

private struct PerformOnAppearSkippingFirstModifier: ViewModifier {
    @State
    private var didAppearOnce = false
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.onAppear {
            defer { didAppearOnce = true }
            guard didAppearOnce else { return }
            action()
        }
    }
}

extension View {
    @inline(__always)
    public func onAppearSkippingFirst(
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(PerformOnAppearSkippingFirstModifier(action: action))
    }
}
