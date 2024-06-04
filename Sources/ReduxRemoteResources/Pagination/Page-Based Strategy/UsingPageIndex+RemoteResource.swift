import RemoteResources

extension Paged.UsingPageIndex {
    public typealias FilteredRemoteResource<
        Element: Identifiable,
        Filter: Equatable
    > = PagedRemoteResource<Element, PagePath, Filter>
    
    public typealias RemoteResource<
        Element: Identifiable
    > = PagedRemoteResource<Element, PagePath, EquatableByDescription<Void>>
}
