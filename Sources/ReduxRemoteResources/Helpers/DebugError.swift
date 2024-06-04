import Foundation

protocol DebugError: Error, LocalizedError, CustomDebugStringConvertible, CustomStringConvertible { }

extension DebugError {
    public var debugDescription: String { description }
    public var errorDescription: String? { description }
}

struct AnyDebugError: DebugError {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}
