![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg)
[![GitHub license](https://img.shields.io/github/license/xxlabaza/SshConfig)](https://github.com/xxlabaza/SshConfig/blob/main/LICENSE.txt)
[![Build Status](https://github.com/xxlabaza/SshConfig/actions/workflows/tests.yml/badge.svg)](https://github.com/xxlabaza/SshConfig/actions)

# SshConfig

The SshConfig makes it quick and easy to load, parse, and decode/encode the SSH configs. It also helps to resolve the properties by hostname and use them safely in your apps (thanks for Optional and static types in Swift).

## Contents

- [Features](#features)
- [Usage](#usage)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)

## Features

- Parsing a SSH config;
- Encode/Decode your config in JSON or text format;
- Resolve the SSH properties for a host by its alias;
- The static type checking SSH properties (yeah...If, in the beginning, I knew that there would be almost 100 properties, I would not begin to describe them!).

## Usage

Let's try to load, parse and decode an SSH config file and look at a base scenario of how to work with it.

**~/.ssh/config** file content:

```
Host gitlab.com github.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/id_rsa
  User xxlabaza

Host my*
  User admin
  Port 2021

Host *
  SetEnv POPA=3000
```

Code example:

```swift
import SshConfig

let config = ssh.Config.load(path: "~/.ssh/config")

let github = config.resolve(for: "github.com")
assert(github.preferredAuthentications == [.publickey])
assert(github.identityFile == ["~/.ssh/id_rsa"])
assert(github.user == "xxlabaza")
assert(github.setEnv == ["POPA": "3000"]) // from 'Host *'
assert(github.port == 22) // the default one

// github.com and gitlab.com resolve the same properties set
assert(github == config.resolve(for: "gitlab.com"))

let myserver = config.resolve(for: "myserver")
assert(myserver.user == "admin")
assert(myserver.port == 2021)
assert(myserver.setEnv == ["POPA": "3000"]) // from 'Host *'

let backend = config.resolve(for: "backend")
assert(backend.user == nil) // the default one
assert(backend.port == 22) // the default one
assert(backend.setEnv == ["POPA": "3000"]) // from 'Host *'
```

The same `ssh.Config` instance can be constructed programmatically, like this:

> **NOTE:** I use variadic list of closures for setting needed properties for `ssh.Properties` instance, which creates inside the `ssh.Host` initializer. I found that approach more similar to the original ssh config file format, plus you can ignore the `ssh.Properties`'s fields order.

```swift
import SshConfig

let config = ssh.Config(
  ssh.Host("gitlab.com github.com",
    { $0.preferredAuthentications = [.publickey] },
    { $0.identityFile = ["~/.ssh/id_rsa"] },
    { $0.user = "xxlabaza" }
  ),
  ssh.Host("my*",
    { $0.user = "admin" },
    { $0.port = 2021 }
  ),
  ssh.Host("*",
    { $0.setEnv = ["POPA": "3000"] }
  )
)

...
```

More code samples and examples are available in the tests (especially in [UsageExample.swift](https://github.com/xxlabaza/SshConfig/blob/master/Tests/SshConfigTests/UsageExample.swift) file).

## Installation

### Requirements

Swift 5.1+

| iOS | watchOS | tvOS | macOS  |
|:---:|:-------:|:----:|:------:|
| 13+ |    6+   |  13+ | 10.15+ |

### Swift Package Manager

> **NOTE:** the instructions below are for using `SwiftPM` without the `Xcode UI`. It's the easiest to go to your Project Settings -> Swift Packages and add SshConfig from there.

[Swift Package Manager](https://swift.org/package-manager/) - **is the recommended installation method**. All you need is to add the following as a dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/xxlabaza/SshConfig.git", from: "1.0.1"),
```

So, your `Package.swift` may look like below:

```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "MyPackage",
  platforms: [ // The SshConfig requires the versions below as a minimum.
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "MyPackage", targets: ["MyPackage"]),
  ],
  dependencies: [
    .package(url: "https://github.com/xxlabaza/SshConfig.git", from: "1.0.1"),
  ],
  targets: [
    .target(name: "MyPackage", dependencies: ["SshConfig"])
  ]
)
```

And then import wherever needed:

```swift
import SshConfig
```

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SshConfig into your Xcode project using CocoaPods, specify it in your Podfile:

```
pod 'SshConfig'
```

And then run:

```
pod install
```

After installing the cocoapod into your project import SshConfig with:

```swift
import SshConfig
```

## Changelog

To see what has changed in recent versions of the project, see the [changelog](./CHANGELOG.md) file.

## Contributing

Please read [contributing](./CONTRIBUTING.md) file for details on my code of conduct, and the process for submitting pull requests to me.

## Versioning

I use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/xxlabaza/SshConfig/tags).

## Authors

* **[Artem Labazin](https://github.com/xxlabaza)** - creator and the main developer.

## License

This project is licensed under the Apache License 2.0 License - see the [license](./LICENSE.txt) file for details.
