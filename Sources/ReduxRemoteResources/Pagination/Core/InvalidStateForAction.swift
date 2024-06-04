import CasePaths

struct InvalidStateForActionWarning: DebugError {
    let description: String
    
    init<Parent, Action: CustomShortStringConvertible, State: CasePathable & CustomShortStringConvertible>(
        _ parentType: Parent.Type,
        action: Action,
        invalidState: State,
        validStates validStatesDescriptions: String...
    ) {
        description = """
        \(String(describing: parentType))
        WARNING:
        Invalid action '\(action.shortDescription)' for state '\(invalidState.shortDescription)'.
        Valid states are '[\(validStatesDescriptions.joined(separator: ", "))]'.
        Perform checks on state before sending this action.
        """
    }
}
