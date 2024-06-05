import RemoteResources

extension Paged.UsingPageIndex {
    public typealias FilteredRemoteResource<
        Element: Identifiable,
        Filter: PagedRemoteResourceFilter
    > = PagedFilterableRemoteResource<Element, PagePath, Filter>
    
    public typealias RemoteResource<
        Element: Identifiable
    > = PagedFilterableRemoteResource<Element, PagePath, EmptyPagedRemoteResourceFilter>
}
