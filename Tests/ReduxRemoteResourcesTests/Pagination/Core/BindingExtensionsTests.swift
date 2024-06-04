@testable import ReduxRemoteResources
import Foundation
import SwiftUI
import XCTest

final class BindingExtensionsTests: XCTestCase {
    @MainActor
    func testDebounceBinding() {
        struct Model {
            var value: Int
        }
        
        let queue = TestDispatchQueue()
        let ref = MutableReference(Model(value: 0))
        
        let binding = Binding<Model>(
            get: {
                ref.value
            }, set: {
                ref.value = $0
            }
        )
        .debounced(delay: 1, with: queue)
        
        binding.wrappedValue = Model(value: 1)
        
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 0)
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 1)
    }
    
    @MainActor
    func testDebouncedEquatableBinding() {
        struct Model: Equatable {
            var value: Int
        }
        
        let queue = TestDispatchQueue()
        let ref = MutableReference(Model(value: 0))
        
        let binding = Binding<Model>(
            get: {
                ref.value
            }, set: {
                ref.value = $0
            }
        )
        .debounced(delay: 1, with: queue)
        
        binding.wrappedValue = Model(value: 0)
        
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 0)
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 0)
        
        binding.wrappedValue = Model(value: 1)
        
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 0)
        queue.advance(by: 0.5)
        XCTAssertEqual(ref.value.value, 1)
    }
}
