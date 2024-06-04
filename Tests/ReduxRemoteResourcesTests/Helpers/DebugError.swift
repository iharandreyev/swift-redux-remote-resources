import Foundation

struct DebugError: Error, LocalizedError, CustomDebugStringConvertible, CustomStringConvertible {
    let description: String
    
    var debugDescription: String { description }
    var errorDescription: String? { description }
    
    init(_ description: String) {
        self.description = description
    }
}
