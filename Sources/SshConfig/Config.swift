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

import Foundation

public extension ssh {

  /// The holder for all SSH hosts and their properties
  /// also provides convenient loading/dumping, parsing,
  /// and resolving methods for a client.
  struct Config: Equatable, Codable {

    /**
    A static method for decoding `ssh.Config` instance from a JSON string.

    ```
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

    - parameter string: The JSON string to decode in `ssh.Config` instance.
    - returns: A new `ssh.Config` instance parsed from the JSON string.
    - throws:
      - The standard `JSONDecoder`'s errors set during decoding.
    */
    public static func from (json string: String) throws -> Config {
      let data = string.data(using: .utf8)!
      return try from(json: data)
    }

    /**
    A static method for decoding `ssh.Config` instance from a JSON's `Data`.

    ```
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

    - parameter data: The JSON `Data` to decode in `ssh.Config` instance.
    - returns: A new `ssh.Config` instance parsed from the JSON `Data`.
    - throws:
      - The standard `JSONDecoder`'s errors set during decoding.
    */
    public static func from (json data: Data) throws -> Config {
      let decoder = JSONDecoder()
      return try decoder.decode(Config.self, from: data)
    }

    /**
    The method loads and parses a new `ssh.Config` by a path from a file.

    ```
    let content = """
    Host myserv
      port 2021
    """
    try! content.write(
      toFile: NSString(string: "~/my-ssh-config").expandingTildeInPath,
      atomically: true,
      encoding: String.Encoding.utf8
    )


    let config = try! ssh.Config.load(path: "~/my-ssh-config")

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
    ```

    - parameter path: The path to a file, which conatins SSH config.
    - returns: A new `ssh.Config` instance parsed from the file.
    - throws:
      - `ssh.ConfigDecoderError` If any value throws an error during decoding.
      - `ssh.ConfigParserError` If any parsing error occurs.
    */
    public static func load (path: String) throws -> Config {
      let filePath = NSString(string: path).expandingTildeInPath
      let content: String
      do {
        content = try String(contentsOfFile: filePath)
      } catch {
        throw ssh.ConfigError.unableToLoad(path: filePath, cause: error)
      }
      return try parse(content)
    }

    /**
    The method parses a new `ssh.Config` from a passed string.

    ```
    let content = """
    Host myserv
      port 2021
    """

    let config = try! ssh.Config.parse(content)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
    ```

    - parameter content: The path to a file, which conatins SSH config.
    - returns: A new `ssh.Config` instance parsed from the passed string.
    - throws:
      - `ssh.ConfigDecoderError` If any value throws an error during decoding.
      - `ssh.ConfigParserError` If any parsing error occurs.
    */
    public static func parse (_ content: String) throws -> Config {
      let decoder = ssh.ConfigDecoder()
      return try decoder.decode(from: content)
    }

    /// The immutable list of the `ssh.Host` instances in the config.
    public let hosts: [Host]

    /**
    The initializer for a `ssh.Config`, which takes list of `ssh.Host`s
    as a variadic parameter.

    - warning: The order matters for a `resolve(for:)` method.

    ```
    let config = ssh.Config(
      ssh.Host("github.com gitlab.com",
        { $0.user = "xxlabaza" },
        { $0.identityFile = ["~/.ssh/id_ed25519"] }
      ),
      ssh.Host("myserv",
        { $0.port = 56 },
        { $0.user = "admin" }
      ),
      ssh.Host("*",
        { $0.port = 2020 },
        { $0.user = "artem" },
        { $0.addKeysToAgent = .yes },
        { $0.forwardX11Timeout = ssh.TimeFormat(minutes: 1, seconds: 15) }
      )
    )

    assert(config.hosts.count == 3)

    assert(config.hosts[0].alias == "github.com gitlab.com")
    assert(config.hosts[0].properties.user == "xxlabaza")

    assert(config.hosts[1].alias == "myserv")
    assert(config.hosts[1].properties.port == 56)

    assert(config.hosts[2].alias == "*")
    assert(config.hosts[2].properties.addKeysToAgent == .yes)
    ```
    */
    public init (_ hosts: Host...) {
      self.init(hosts)
    }

    init (_ hosts: [Host]) {
      self.hosts = hosts
    }

    /**
    The method converts the `ssh.Config` into a JSON `Data` object.

    ```
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let data = try! config.toJsonData()

    assert(jsonEquals(
      actual: data,
      expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
    ))
    ```

    - returns: A new JSON `Data` instance from this `ssh.Config`.
    - throws:
      - The standard `JSONEncoder`'s errors set during encoding.
    */
    public func toJsonData () throws -> Data {
      let encoder = JSONEncoder()
      return try encoder.encode(self)
    }

    /**
    The method converts the `ssh.Config` into a JSON string.

    ```
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let json = try! config.toJsonString()

    assert(jsonEquals(
      actual: json,
      expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
    ))
    ```

    - returns: A new JSON string from this `ssh.Config`.
    - throws:
      - The standard `JSONEncoder`'s errors set during encoding.
    */
    public func toJsonString () throws -> String {
      let data = try toJsonData()
      return String(data: data, encoding: .utf8)!
    }

    /**
    The method converts the `ssh.Config` instance into a string.


    ```
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let string = try! config.toString()

    assert(string == """
    Host myserv
      Port 15
    """)
    ```

    - returns: A string representation of this `ssh.Config` instance.
    - throws:
      - `ssh.ConfigEncoderError` If any value throws an error during encoding.
    */
    public func toString () throws -> String {
      let encoder = ssh.ConfigEncoder()
      return try encoder.encode(self)
    }

    /**
    Dumps the current `ssh.Config` instance into a file by its path.

    If the file doesn't exist by set path - it will be created.
    The file's encodig - UTF-8.

    ```
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

    - parameter path: The path to a file, where to save this `ssh.Config`'s string representation.
    - throws:
      - `ssh.ConfigEncoderError` If any value throws an error during encoding.
      - `ssh.ConfigError.unableToDump` If any IO exception occurs.
    */
    public func dump (to path: String) throws {
      let content = try toString()
      let filePath = NSString(string: path).expandingTildeInPath
      do {
        try content.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
      } catch {
        throw ssh.ConfigError.unableToDump(path: filePath, cause: error)
      }
    }

    /**
    It resolves a `ssh.Properties` by a hostname.

    The resolving algorithm is the following:
    - check all `ssh.Config`'s hosts from bottom to top by their aliases
      (there could be the wildcards with the '*' and '?' signs);
    - merge all matched host's `ssh.Properties` in one.

    ```
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

    - note: The method always returns a new instance of `ssh.Properties`,
    so the future changes of it don't affect the config.

    - parameter host: The hostname, which needs to resolve.
    - returns: A new `ssh.Properties` instance for the host.
    */
    public func resolve (for host: String) -> Properties {
      let matchProperties = hosts
        .filter { $0.match(host) }
        .map { $0.properties }
        .reversed()

      return matchProperties.count == 0
             ? clone(ssh.Properties.defaults)
             : matchProperties.reduce(ssh.Properties.defaults, { merge($0, $1) })
    }

    private func merge (_ left: Properties, _ right: Properties) -> Properties {
      let encoder = JSONEncoder()
      let decoder = JSONDecoder()

      let leftData = try! encoder.encode(left)
      let rightData = try! encoder.encode(right)

      var leftDict = try! JSONSerialization.jsonObject(with: leftData) as! [String: Any]
      let rightDict = try! JSONSerialization.jsonObject(with: rightData) as! [String: Any]

      leftDict.merge(rightDict) { (_, new) in new }

      let result = try! JSONSerialization.data(withJSONObject: leftDict)
      return try! decoder.decode(Properties.self, from: result)
    }

    private func clone (_ value: Properties) -> Properties {
      let encoder = JSONEncoder()
      let data = try! encoder.encode(value)

      let decoder = JSONDecoder()
      return try! decoder.decode(Properties.self, from: data)
    }
  }
}
