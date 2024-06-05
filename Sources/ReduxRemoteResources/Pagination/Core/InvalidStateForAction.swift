import CasePaths

struct InvalidStateForActionWarning: DebugError {
    let description: String
    
    init<Parent, Action, State>(
        _ parentType: Parent.Type,
        action: Action,
        invalidState: State,
        validStates validStatesDescriptions: String...
    ) {
        description = """
        \(String(describing: parentType))
        WARNING:
        Invalid action '\(ShortDebugDescription(action))'
        for state '\(ShortDebugDescription(invalidState))'.
        
        Valid states are:
        \(validStatesDescriptions.map { "- '\($0)'" }.joined(separator: ",\n"))
        
        Perform checks on state before sending this action.
        """
    }
}

private struct ShortDebugDescription: CustomStringConvertible {
    let description: String
    
    init(_ value: Any) {
        var rawValue = "\(value)"
        
        var components: [String] = []
        
        while let openBracket = rawValue.range(of: "(") {
            guard let closeBracket = rawValue.range(of: ")", options: .backwards) else {
                break
            }
            
            let prefix = rawValue[rawValue.startIndex ..< openBracket.lowerBound].components(separatedBy: ".").last!
            
            components.append(prefix)
            
            let innerContent = rawValue[openBracket.lowerBound ..< closeBracket.upperBound]
            guard innerContent.range(of: ".") == nil else {
                break
            }
            
            rawValue = String(innerContent)
        }
        
        guard !components.isEmpty else {
            self.description = rawValue
            return
        }
        
        let prefix = components.removeFirst()
        let suffix = components.reversed().reduce(into: "") {
            $0 = "(\($1)\($0))"
        }
        
        let description = prefix + suffix
        
        self.description = description
    }
}
