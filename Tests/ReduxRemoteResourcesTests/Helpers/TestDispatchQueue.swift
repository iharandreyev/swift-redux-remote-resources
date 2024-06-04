import Foundation
import ReduxRemoteResources

final class TestDispatchQueue: DispatchQueueType {
    private var time: Date = Date(timeIntervalSinceNow: 0)
    private var workItems: [Date: DispatchWorkItem] = [:]
    
    public func advance(by seconds: TimeInterval) {
        guard seconds > 0 else {
            assertionFailure("Can't advance by \(seconds)")
            return
        }

        time = time.addingTimeInterval(seconds)
        
        let keys = workItems.keys.filter {
            let diff = time >= $0
            return diff
        }
        
        for key in keys {
            guard let workItem = workItems[key] else { continue }
            
            guard !workItem.isCancelled else {
                workItems.removeValue(forKey: key)
                continue
            }
            
            workItem.perform()
            workItems.removeValue(forKey: key)
        }
    }
    
    public func async(execute workItem: DispatchWorkItem) {
        let dispatchTime = time.addingTimeInterval(0.017)
        workItems[dispatchTime] = workItem
    }
    
    public func asyncAfter(delay: TimeInterval, execute workItem: DispatchWorkItem) {
        let dispatchTime = time.addingTimeInterval(delay)
        workItems[dispatchTime] = workItem
    }
}
