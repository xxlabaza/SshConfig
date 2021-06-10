// swift-tools-version:5.1
//===----------------------------------------------------------------------===//
//
// This source file is part of the SshConfig open source project
//
// Copyright (c) 2021 Artem Labazin
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SshConfig project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "SshConfig",
  platforms: [
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "SshConfig", targets: ["SshConfig"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
        name: "SshConfig",
        dependencies: []),

    .testTarget(
        name: "SshConfigTests",
        dependencies: ["SshConfig"]),
  ]
)
