import RemoteResources

extension Paged.UsingPageIndex {
    typealias FilteredRemoteResource<
        Element: Identifiable,
        Filter: Equatable
    > = PagedRemoteResource<Element, PagePath, Filter>
    
    typealias RemoteResource<
        Element: Identifiable
    > = PagedRemoteResource<Element, PagePath, EquatableByDescription<Void>>
}
