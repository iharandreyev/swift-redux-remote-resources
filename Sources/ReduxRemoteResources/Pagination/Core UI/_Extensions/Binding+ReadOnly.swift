import SwiftUI

#warning("TODO: Cover with tests")
extension Binding {
    static func readOnly(get: @escaping () -> Value) -> Self {
        Binding(
            get: get,
            set: { _ in
                assertionFailure("You can't set a value into a readOnly binding")
            }
        )
    }
    
    static func readOnly(_ get: @escaping @autoclosure () -> Value) -> Self {
        Self.readOnly(get: get)
    }
}
