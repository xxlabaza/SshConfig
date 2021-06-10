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

public extension ssh {

  typealias HostAlias = String
  typealias LowercasedSshPropertyName = String
  typealias SshPropertyValues = [String]
  typealias SshProperties = [LowercasedSshPropertyName: SshPropertyValues]
  typealias ParsedSshConfig = [(HostAlias, SshProperties)]

  /// A string parser for SSH configs.
  struct ConfigParser {

    public init () {
      // empty
    }

    /**
    Parses a string into a collection of the hosts and their properties.

    ```
    let content = """
    Host myserv
      User alice
      Port 2021
    """

    let parser = ssh.ConfigParser()
    let parsedConfig = try! parser.parse(content)
    assert(parsedConfig.count == 1)

    let (host, properties) = parsedConfig[0]
    assert(host == "myserv")
    assert(properties["user"] == ["alice"])
    assert(properties["port"] == ["2021"])
    ```

    - parameter content: A SSH config string representation.
    - returns: A collection of the parsed hosts and their properties.
    - throws:
      - `ssh.ConfigParserError` If any parsing error occurs.
    */
    public func parse (_ content: String) throws -> ParsedSshConfig {
      var state: State = .expectingHost
      let context = ParseContext()

      for token in Tokens(base: content) {
        if case let .invalid(error) = token {
          throw error
        }

        if state == .expectingPropertyName, case .key("Host") = token {
          state = .expectingHost
        }

        switch state {
        case .expectingHost:
          try handleHost(token, context)
          state = .expectingAlias
        case .expectingAlias:
          try handleAlias(token, context)
          state = .expectingPropertyName
        case .expectingPropertyName:
          try handlePropertyName(token, context)
          state = .expectingPropertyValue
        case .expectingPropertyValue:
          try handlePropertyValue(token, context)
          state = .expectingPropertyName
        }
      }
      try handleHost(.key("Host"), context)

      return context.result
    }

    private func handleHost (_ token: Token, _ context: ParseContext) throws {
      guard case .key("Host") = token else {
        throw ConfigParserError.unexpectedToken("\(token)")
      }
      if let hostAliases = context.currentHostAlias {
        if context.currentProperties.count == 0 {
          throw ConfigParserError.noPropertiesForHost
        }
        context.result.append((hostAliases, context.currentProperties))
      }
      context.currentHostAlias = nil
      context.currentProperties = [:]
    }

    private func handleAlias (_ token: Token, _ context: ParseContext) throws {
      guard case .value(let alias) = token else {
        throw ConfigParserError.unexpectedToken("\(token)")
      }
      if alias.isBlank {
        throw ConfigParserError.noAliasForHost
      }
      context.currentHostAlias = alias
    }

    private func handlePropertyName (_ token: Token, _ context: ParseContext) throws {
      guard case .key(let name) = token else {
        throw ConfigParserError.unexpectedToken("\(token)")
      }
      context.currentPropertyName = name.lowercased()
    }

    private func handlePropertyValue (_ token: Token, _ context: ParseContext) throws {
      guard let propertyName = context.currentPropertyName else {
        throw ConfigParserError.internalError("There is no property name for \(token)")
      }

      switch token {
      case .value(let value):
        var propertyValues = context.currentProperties[propertyName] ?? []
        propertyValues.append(value)
        context.currentProperties[propertyName] = propertyValues
      default:
        throw ConfigParserError.unexpectedToken("\(token)")
      }
    }

    private enum State {

      case expectingHost
      case expectingAlias
      case expectingPropertyName
      case expectingPropertyValue
    }

    private class ParseContext {

      var result: ParsedSshConfig = []
      var currentHostAlias: HostAlias? = nil
      var currentProperties: SshProperties = [:]
      var currentPropertyName: LowercasedSshPropertyName? = nil
    }
  }
}
