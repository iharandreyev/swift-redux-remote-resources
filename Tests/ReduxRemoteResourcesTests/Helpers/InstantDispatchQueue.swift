import Foundation
import ReduxRemoteResources

final class InstantDispatchQueue: DispatchQueueType {
    public func async(execute workItem: DispatchWorkItem) {
        workItem.perform()
    }
    
    public func asyncAfter(delay: TimeInterval, execute workItem: DispatchWorkItem) {
        workItem.perform()
    }
}
