// swift-tools-version: 5.10

import PackageDescription

private let targetName = "ReduxRemoteResources"
private let testTargetName = "\(targetName)Tests"

let package = Package(
    name: "swift-rexux-remote-resources",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: targetName,
            type: .static,
            targets: [targetName]
        ),
    ],
    dependencies: Dependencies.all.map(\.packageDependency),
    targets: [
        .target(
            name: targetName,
            dependencies: Dependencies.all.map(\.targetDependency)
        ),
        .testTarget(
            name: testTargetName,
            dependencies: [
                .byName(name: targetName),
                Dependencies.theComposableArchitecture.targetDependency,
                Dependencies.remoteResources.targetDependency
            ]
        )
    ]
)

// MARK: - Dependencies

enum Dependencies {
    static let identifiedCollections = RemotePackageDependency(
        productName: "IdentifiedCollections",
        packageName: "swift-identified-collections",
        url: "https://github.com/pointfreeco/swift-identified-collections",
        version: "1.0.2"
    )
    
    static let theComposableArchitecture = RemotePackageDependency(
        productName: "ComposableArchitecture",
        packageName: "swift-composable-architecture",
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        version: "1.10.4"
    )
    
//    static let remoteResources = RemotePackageDependency(
//        productName: "RemoteResources",
//        packageName: "swift-remote-resources",
//        url: "https://github.com/iharandreyev/swift-remote-resources",
//        version: "0.1.0"
//    )
    
    static let remoteResources = LocalPackageDependency(
        name: "RemoteResources",
        path: "../swift-remote-resources"
    )

    static let all: [Dependency] = [
        identifiedCollections,
        theComposableArchitecture,
        remoteResources
    ]
}

// MARK: - Helpers

protocol Dependency {
    var packageDependency: Package.Dependency { get }
    var targetDependency: Target.Dependency { get }
}

struct RemotePackageDependency: Dependency {
    let productName: String
    let packageName: String
    let url: String
    let version: Version
    
    var packageDependency: Package.Dependency { .package(url: url, exact: version) }
    var targetDependency: Target.Dependency { .product(name: productName, package: packageName) }
}

struct LocalPackageDependency: Dependency {
    private let name: String
    private let path: String
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
    
    var packageDependency: Package.Dependency { .package(name: name, path: path) }
    var targetDependency: Target.Dependency { .byName(name: name) }
}
