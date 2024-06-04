import RemoteResources

extension Paged.UsingPageIndex {
    public typealias FilteredRemoteResource<
        Element: Identifiable,
        Filter: PagedRemoteResourceFilter
    > = PagedRemoteResource<Element, PagePath, Filter>
    
    public typealias RemoteResource<
        Element: Identifiable
    > = PagedRemoteResource<Element, PagePath, EmptyPagedRemoteResourceFilter>
}
