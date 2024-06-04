import ComposableArchitecture

extension Reduce {
    @inlinable
    public init(
        _ reduce: @escaping (_ state: inout State, _ action: Action) throws -> Effect<Action>,
        catch: @escaping (Error) -> Action
    ) {
        self.init { state, action in
            do {
                return try reduce(&state, action)
            } catch {
                return .send(`catch`(error))
            }
        }
    }
}

