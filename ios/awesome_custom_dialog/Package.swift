// swift-tools-version:5.9
// SPM scaffold only — awesome_custom_dialog is a pure-Dart package with no
// native iOS code, and this manifest is not yet wired into pubspec.yaml
// (no `flutter: plugin: platforms: ios:` section), so Flutter tooling does
// not pick it up today. It exists as a starting point for potential future
// native additions; see CHANGELOG.md for details.
import PackageDescription

let package = Package(
  name: "awesome_custom_dialog",
  platforms: [
    .iOS("16.0")
  ],
  products: [
    .library(name: "awesome-custom-dialog", targets: ["awesome_custom_dialog"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "awesome_custom_dialog",
      dependencies: []
    )
  ]
)
