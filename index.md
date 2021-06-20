## Overview

The SshConfig makes it quick and easy to load, parse, and decode/encode the SSH configs. It also helps to resolve the properties by hostname and use them safely in your apps (thanks for Optional and static types in Swift).

### Contents

- [Features](#features)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Usage](#usage)
  - [Parsing](#parsing)
  - [Decoding](#decoding)
  - [Encoding](#encoding)
  - [Resolving](#resolving)
- [Dump and Load](#dump-and-load)
- [JSON](#json)
- [Errors](#errors)
  - [EmptyKeyToken](#emptykeytoken)
  - [EmptyValueToken](#emptyvaluetoken)
  - [IllegalTokensDelimiter](#illegaltokensdelimiter)
  - [UnexpectedToken](#unexpectedtoken)
  - [NoAliasForHost](#noaliasforhost)
  - [NoPropertiesForHost](#nopropertiesforhost)
  - [UnableToDecode](#unabletodecode)
  - [UnableToLoad](#unabletoload)
  - [UnableToDump](#unabletodump)

### Features

- Parsing a SSH config;
- Encode/Decode your config in JSON or text format;
- Resolve the SSH properties for a host by its alias;
- The static type checking SSH properties (yeah...If, in the beginning, I knew that there would be almost 100 properties, I would not begin to describe them!).

### Installation

#### Requirements

Swift 5.1+

| iOS | watchOS | tvOS | macOS  |
|:---:|:-------:|:----:|:------:|
| 13+ |    6+   |  13+ | 10.15+ |

##### Swift Package Manager

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

### Usage

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

#### Parsing

```swift
let content = """
Host myserv
  User alice
  Port 2021
"""

let parser = ssh.ConfigParser()
let parsedConfig = try parser.parse(content)
assert(parsedConfig.count == 1)

let (host, properties) = parsedConfig[0]
assert(host == "myserv")
assert(properties["user"] == ["alice"])
assert(properties["port"] == ["2021"])
```

#### Decoding

```swift
let content = """
Host myserv
  User alice
  Port 2021
"""

let decoder = ssh.ConfigDecoder()
let config = try decoder.decode(from: content)

assert(config.hosts.count == 1)
assert(config.hosts[0].alias == "myserv")
assert(config.hosts[0].properties.user == "alice")
assert(config.hosts[0].properties.port == 2021)
```

The same as above, but with an implicit `ssh.ConfigParser` call:

```swift
let content = """
Host myserv
  port 2021
"""

let config = try! ssh.Config.parse(content)

assert(config.hosts.count == 1)
assert(config.hosts[0].alias == "myserv")
assert(config.hosts[0].properties.port == 2021)
```

#### Encoding

```swift
let config = ssh.Config(
  ssh.Host("myserv",
    { $0.user = "alice" },
    { $0.port = 2021 }
  )
)

let encoder = ssh.ConfigEncoder()
let string = try encoder.encode(config)

assert(string == """
Host myserv
  Port 2021
  User alice
""")
```

The same as above, but with an implicit `ssh.ConfigEncoder` call:

```swift
let config = ssh.Config(
  ssh.Host("myserv", { $0.port = 15 })
)
let string = try! config.toString()

assert(string == """
Host myserv
  Port 15
""")
```

#### Resolving

```swift
let config = ssh.Config(
  ssh.Host("github.com gitlab.com",
    { $0.user = "xxlabaza" }
  ),
  ssh.Host("my*",
    { $0.user = "admin" },
    { $0.port = 56 }
  ),
  ssh.Host("*",
    { $0.user = "artem" },
    { $0.port = 2020 }
  )
)

let github = config.resolve(for: "github.com")
assert(github.user == "xxlabaza")
assert(github.port == 2020)

let gitlab = config.resolve(for: "gitlab.com")
assert(gitlab.user == "xxlabaza")
assert(gitlab.port == 2020)

let myserv = config.resolve(for: "myserv")
assert(myserv.user == "admin")
assert(myserv.port == 56)

let example = config.resolve(for: "example.com")
assert(example.user == "artem")
assert(example.port == 2020)
```

### Dump and Load

You can **dump** an `ssh.Config` instance into a file:

```swift
let config = ssh.Config(
  ssh.Host("myserv", { $0.port = 15 })
)
try! config.dump(to: "~/my-ssh-config")

let filePath = NSString(string: "~/my-ssh-config").expandingTildeInPath
assert(FileManager.default.fileExists(atPath: filePath))
assert(try! String(contentsOfFile: filePath) == """
Host myserv
  Port 15
""")
```

And read a config like this:

```swift
let content = """
Host myserv
  port 2021
"""
try content.write(
  toFile: NSString(string: "~/my-ssh-config").expandingTildeInPath,
  atomically: true,
  encoding: String.Encoding.utf8
)


let config = try! ssh.Config.load(path: "~/my-ssh-config")

assert(config.hosts.count == 1)
assert(config.hosts[0].alias == "myserv")
assert(config.hosts[0].properties.port == 2021)
```

### JSON

Writing `SshConfig` to a `JSON` **string**:

```swift
let config = ssh.Config(
  ssh.Host("myserv", { $0.port = 15 })
)
let json = try! config.toJsonString()

assert(jsonEquals(
  actual: json,
  expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
))
```

Writing `SshConfig` to a `JSON` **Data**:

```swift
let config = ssh.Config(
  ssh.Host("myserv", { $0.port = 15 })
)
let data = try! config.toJsonData()

assert(jsonEquals(
  actual: data,
  expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
))
```

Reading `SshConfig` from a `JSON` **string**:

```swift
let string = """
{
  "hosts": [
    {
      "alias": "myserv",
      "properties": {
        "port": 2021
      }
    }
  ]
}
"""

let config = try! ssh.Config.from(json: string)

assert(config.hosts.count == 1)
assert(config.hosts[0].alias == "myserv")
assert(config.hosts[0].properties.port == 2021)
```

Reading `SshConfig` from a `JSON` **Data**:

```swift
let string = """
{
  "hosts": [
    {
      "alias": "myserv",
      "properties": {
        "port": 2021
      }
    }
  ]
}
"""
let data = string.data(using: .utf8)!

let config = try! ssh.Config.from(json: data)

assert(config.hosts.count == 1)
assert(config.hosts[0].alias == "myserv")
assert(config.hosts[0].properties.port == 2021)
```

### Errors

#### EmptyKeyToken

This error could be thrown by `ssh.ConfigParser`s if there was an empty string for an expected key token (`Host` or property name).

```swift
let content = """
Host myserv
  =user
  "" 2021
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch ssh.ConfigParserError.emptyKeyToken {
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### EmptyValueToken

This error could be thrown by `ssh.ConfigParser`s if there was an empty string for an expected value token (host's alias or property value).

```swift
let content = """
Host myserv
  user
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch ssh.ConfigParserError.emptyValueToken {
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### IllegalTokensDelimiter

Found an invalid **delimiter** character **after** a token.

```swift
let content = """
Host myserv
  user?xxlabaza
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch let ssh.ConfigParserError.illegalTokensDelimiter(after, delimiter) {
  assert(after == "user")
  assert(delimiter == "?")
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### UnexpectedToken

A **token** is in an unexpected place.

```swift
let content = """
host
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch let ssh.ConfigParserError.unexpectedToken(token) {
  assert(token == "key(\"host\")")
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### NoAliasForHost

There is no alias for parsing `Host` config's section.

```swift
let content = """
Host " "
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch ssh.ConfigParserError.noAliasForHost {
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### NoPropertiesForHost

A `Host` config section doesn't have any property inside.

```swift
let content = """
Host myserv
"""

var errorCatched = false
do {
  _ = try ssh.ConfigParser().parse(content)
} catch ssh.ConfigParserError.noPropertiesForHost {
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### UnableToDecode

An attempt was made to decode a **value** by **path** as type.

```swift
let content = """
Host *
  port abc
"""

var errorCatched = false
do {
  _ = try ssh.ConfigDecoder().decode(from: content)
} catch let ssh.ConfigDecoderError.unableToDecode(path, value, type) {
  assert(path == "port")
  assert(value == "abc")
  assert(type == UInt16.self)
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### UnableToLoad

Can't load a config by **path** because of **cause**.

```swift
var errorCatched = false
do {
  _ = try ssh.Config.load(path: "/nonexistent/path")
} catch let ssh.ConfigError.unableToLoad(path, cause) {
  assert(path == "/nonexistent/path")
  assert(type(of: cause) == NSError.self)
  // Different messages depend on OS and Swift version,
  // but they say the same - 'No such file'.
  assert(cause.localizedDescription.contains("o such file"))
  errorCatched = true
} catch {}
assert(errorCatched)
```

#### UnableToDump

Can't dump a config by **path** because of **cause**.

```swift
let config = ssh.Config()

var errorCatched = false
do {
  try config.dump(to: "/nonexistent/path")
} catch let ssh.ConfigError.unableToDump(path, cause) {
  assert(path == "/nonexistent/path")
  assert(type(of: cause) == NSError.self)
  // Different messages depend on OS and Swift version,
  // but they say the same - 'file doesn’t exist'.
  assert(cause.localizedDescription.contains(" doesn’t exist."))
  errorCatched = true
} catch {}
assert(errorCatched)
```
