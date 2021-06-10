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

  /// An object that decodes instances of a `ssh.Config` type from string.
  struct ConfigDecoder {

    public init () {
      // empty
    }

    /**
    Returns a `ssh.Config` instance, decoded from a string you set.

    ```
    let content = """
    Host myserv
      User alice
      Port 2021
    """

    let decoder = ssh.ConfigDecoder()
    let config = try! decoder.decode(from: content)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.user == "alice")
    assert(config.hosts[0].properties.port == 2021)
    ```

    - parameter string: The SSH config string to decode.
    - returns: A new parsed and decoded `ssh.Config` instance.
    - throws:
      - `ssh.ConfigDecoderError` If any value throws an error during decoding.
      - `ssh.ConfigParserError` If any parsing error occurs.
    */
    public func decode (from string: String) throws -> ssh.Config {
      var hosts: [ssh.Host] = []
      let parser = ssh.ConfigParser()

      for (alias, var parsedProperties) in try parser.parse(string) {
        let context = DecodingContext(parsedProperties)

        let decoder = InternalSshConfigDecoder(for: context)
        var properties = try ssh.Properties(from: decoder)

        for parsedPropertyName in context.parsedPropertyNames {
          parsedProperties.removeValue(forKey: parsedPropertyName)
        }
        if parsedProperties.isEmpty == false {
          properties.unparsed = parsedProperties
        }

        let host = ssh.Host(alias, properties)
        hosts.append(host)
      }
      return ssh.Config(hosts)
    }
  }
}

struct InternalSshConfigDecoder: Decoder {

  let context: DecodingContext

  var codingPath: [CodingKey] {
    return context.codingPath
  }

  var userInfo: [CodingUserInfoKey:Any] = [:]

  init (for context: DecodingContext) {
    self.context = context
  }

  func container<Key> (keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    return KeyedDecodingContainer(ConfigDecodingContainer(for: context, rootDecoder: self))
  }

  func unkeyedContainer () throws -> UnkeyedDecodingContainer {
    return ConfigUnkeyedDecodingContainer(for: context, rootDecoder: self)
  }

  func singleValueContainer () throws -> SingleValueDecodingContainer {
    return ConfigSingleValueDecodingContainer(for: context, rootDecoder: self)
  }
}
