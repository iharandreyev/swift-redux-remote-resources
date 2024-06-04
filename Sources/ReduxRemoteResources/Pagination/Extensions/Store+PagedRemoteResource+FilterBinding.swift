import ComposableArchitecture
import RemoteResources
import SwiftUI

extension Store {
    func filter<
        Element: Identifiable,
        PagePath: PagePathType,
        Filter: Equatable
    >() -> Binding<Filter?> where State == PagedRemoteResourceState<Element, PagePath, Filter>, Action == PagedRemoteResourceAction<Element, PagePath, Filter> {
        Binding(
            get: { [weak self] in
                self?.state.filter
            },
            set: { [weak self] newValue in
                guard let self else { return }
                guard newValue != self.state.filter else { return }
                self.send(.view(.applyFilter(newValue)))
            }
        )
    }
}
