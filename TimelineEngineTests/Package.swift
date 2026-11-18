// swift-tools-version:5.9
// Unit tests for the Timeline Builder engine, run outside the iOS app target:
//
//   cd TimelineEngineTests && swift test
//
// Sources/TimelineCore holds symlinks to the app's real engine files
// (DailyIDo/Models/WeddingTimeline.swift and DailyIDo/Services/TimelineEngine.swift),
// so these tests always exercise the code that ships.
import PackageDescription

let package = Package(
    name: "TimelineEngineTests",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "TimelineCore", path: "Sources/TimelineCore"),
        .testTarget(name: "TimelineCoreTests", dependencies: ["TimelineCore"], path: "Tests/TimelineCoreTests"),
    ]
)
