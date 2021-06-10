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

  /// The object, which contains everything related to a host - its alias and properties.
  struct Host: Equatable, Codable {

    public static func == (left: Host, right: Host) -> Bool {
      return left.alias.toTokens() == right.alias.toTokens() &&
             left.properties == right.properties
    }

    /// The host's alias.
    public let alias: String

    /// The host's properties.
    public let properties: Properties

    var aliasAsPattern: Pattern {
      let string = alias.toTokens()
        .map { Pattern.from(wildcard: $0) }
        .map { $0.string }
        .joined(separator: "|")

      return Pattern("(\(string))")
    }

    /**
    This is the primary initializer, making it look like
    the native SSH config file format.

    ```
    let host = ssh.Host("myserv",
      { $0.user = "admin" },
      { $0.port = 2021 }
    )

    assert(host.alias == "myserv")
    assert(host.properties.user == "admin")
    ```

    - parameter alias: The alias for the host.
    - parameter modifiers: The variadic list of closures for setting needed
      properties for `ssh.Properties` instance, which creates inside this initializer.
    */
    public init (_ alias: String, _ modifiers: (inout Properties) -> Void...) {
      var properties = Properties()
      for modifier in modifiers {
        modifier(&properties)
      }

      self.init(alias, properties)
    }

    /**
    The alternative initializer.

    ```
    var properties = ssh.Properties.create()
    properties.user = "admin"
    properties.port = 2021

    let host = ssh.Host("myserv", properties)

    assert(host.alias == "myserv")
    assert(host.properties.user == "admin")
    ```

    - parameter alias: The alias for the host.
    - parameter properties: The properties for the host.
    */
    public init (_ alias: String, _ properties: ssh.Properties = ssh.Properties.defaults) {
      self.alias = alias
      self.properties = properties
    }

    func match (_ alias: String) -> Bool {
      return aliasAsPattern.matcher(alias).matches()
    }
  }
}
