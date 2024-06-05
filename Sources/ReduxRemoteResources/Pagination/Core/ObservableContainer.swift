import ComposableArchitecture

@ObservableState
@propertyWrapper
@dynamicMemberLookup
public struct ObservableContainer<Value> {
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

extension ObservableContainer: Equatable where Value: Equatable { }
