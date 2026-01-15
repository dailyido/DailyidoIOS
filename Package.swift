// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DailyIDo",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DailyIDo",
            targets: ["DailyIDo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios", from: "4.0.0"),
        .package(url: "https://github.com/superwall-me/Superwall-iOS", from: "3.0.0"),
        .package(url: "https://github.com/ceeK/Solar", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "DailyIDo",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "SuperwallKit", package: "Superwall-iOS"),
                .product(name: "Solar", package: "Solar"),
            ]),
    ]
)
