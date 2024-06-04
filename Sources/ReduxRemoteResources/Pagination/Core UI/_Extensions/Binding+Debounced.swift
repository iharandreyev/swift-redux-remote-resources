import Foundation
import SwiftUI

extension Binding {
    @_disfavoredOverload
    public func debounced(
        delay: TimeInterval = 1,
        with queue: DispatchQueueType = DispatchQueue.main
    ) -> Self {
        let workItem = MutableReference<DispatchWorkItem?>(nil)
        
        return Binding(
            get: {
                wrappedValue
            },
            set: { newValue in
                workItem.value?.cancel()
                workItem.value = DispatchWorkItem {
                    self.wrappedValue = newValue
                }
                
                queue.asyncAfter(delay: delay, execute: workItem.value!)
            }
        )
    }
    
    public func debounced(
        delay: TimeInterval = 1,
        with queue: DispatchQueueType = DispatchQueue.main
    ) -> Self where Value: Equatable {
        let workItem = MutableReference<DispatchWorkItem?>(nil)
        
        return Binding(
            get: {
                wrappedValue
            },
            set: { newValue in
                guard newValue != wrappedValue else { return }
                
                workItem.value?.cancel()
                workItem.value = DispatchWorkItem {
                    self.wrappedValue = newValue
                }
                
                queue.asyncAfter(delay: delay, execute: workItem.value!)
            }
        )
    }
}
