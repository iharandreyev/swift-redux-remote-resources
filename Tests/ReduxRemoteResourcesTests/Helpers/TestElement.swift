import IdentifiedCollections
import RemoteResources

typealias TestElement = Identified<String, String>

extension TestElement {
    static func test(_ value: Value) -> Self {
        Self(value, id: value)
    }
}
