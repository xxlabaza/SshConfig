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

  /// An object that encodes instances of a `ssh.Config` type as string.
  struct ConfigEncoder {

    public init () {
      // empty
    }

    /**
    Returns a string representation of the value you supply.

    ```
    let config = ssh.Config(
      ssh.Host("myserv",
        { $0.user = "alice" },
        { $0.port = 2021 }
      )
    )

    let encoder = ssh.ConfigEncoder()
    let string = try! encoder.encode(config)

    assert(string == """
    Host myserv
      Port 2021
      User alice
    """)
    ```

    - parameter config: The value to encode as string.
    - returns: A string representation of the value you supply.
    - throws:
      - `ssh.ConfigEncoderError` when a generic encoding internal error occurred.
    */
    public func encode (_ config: Config) throws -> String {
      var result: [String] = []

      for host in config.hosts {
        result.append("Host \(host.alias)")

        for (key, value) in try toKeyValue(host.properties) {
          let values = key == "unparsed"
                       ? processUnparsed(value)
                       : process(name: key, value: value)

          values
            .map { "  \($0.0) \($0.1)" }
            .forEach { result.append($0) }
        }
      }
      return result.joined(separator: "\n")
    }

    private func toKeyValue (_ properties: Properties) throws -> [(key: String, value: Any)] {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(properties)
        let dictionary = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return dictionary.sorted(by: keyNameAsc)
      } catch {
        throw ssh.ConfigEncoderError.internalError("Unable to serialize properties", cause: error)
      }
    }

    private func process (name: String, value: Any) -> [(String, String)] {
      let key = name.firstCapitalized

      switch value {
      case let list as [String]:
        if let separator = Properties.delimiter(for: name) {
          return [(key, list.joined(separator: separator))]
        }
        return list.map { (key, quotedIfNeed($0)) }

      case let dictionary as [String: String]:
        return dictionary
          .sorted(by: keyNameAsc)
          .map { (key, "\($0.0)=\(quotedIfNeed($0.1))") }

      case let string as String:
        return [(key, quotedIfNeed(string))]

      default:
        return [(key, "\(value)")]
      }
    }

    private func processUnparsed (_ value: Any) -> [(String, String)] {
      let dictionary = value as! [String: [String]]
      return dictionary
          .sorted(by: keyNameAsc)
          .flatMap { entry in
            entry.value
              .map { quotedIfNeed($0) }
              .map { (entry.key, $0) }
          }
    }

    private func quotedIfNeed (_ string: String) -> String {
      return string.isBlank
             ? "\"\(string)\""
             : string
    }

    private func keyNameAsc (left: (String, Any), right: (String, Any)) -> Bool {
      return left.0 < right.0
    }
  }
}
