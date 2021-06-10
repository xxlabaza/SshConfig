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

struct Tokens: Sequence {

  let base: String

  func makeIterator () -> TokensIterator {
    return TokensIterator(remaining: base[...])
  }
}

enum Token: Equatable {

  case key(String)
  case value(String)
  case invalid(ssh.ConfigParserError)
}

struct TokensIterator: IteratorProtocol {

  private static let SKIP_CHARS: CharacterSet = {
    var result = CharacterSet()
    result.formUnion(.whitespacesAndNewlines)
    result.insert("#")
    return result
  }()

  private static let KEY_VALUE_DELIMITER_CHARS: CharacterSet = {
    var result = CharacterSet()
    result.formUnion(.whitespaces)
    result.insert("=")
    return result
  }()

  var remaining: String.SubSequence
  var state: State = .expectingKey

  mutating func next() -> Token? {
    skip(TokensIterator.SKIP_CHARS)

    switch state {
    case .expectingKey:
      let substring = remaining.prefix(while: { CharacterSet.alphanumerics.contains($0) })
      let key = String(substring.unquoted())
      if key.isBlank {
        return error(.emptyKeyToken)
      }
      remaining = remaining.dropFirst(substring.count)

      if let nextChar = remaining.first, TokensIterator.KEY_VALUE_DELIMITER_CHARS.contains(nextChar) == false {
        return error(.illegalTokensDelimiter(after: key, delimiter: nextChar))
      }

      state = .expectingValue
      return .key(key)
    case .expectingValue:
      var value = remaining.prefix(while: { CharacterSet.newlines.contains($0) == false })
      if value.count <= 0 {
        return error(.emptyValueToken)
      }
      remaining = remaining.dropFirst(value.count)

      if value.first == "=" {
        value = value.dropFirst()
      }
      let result = String(value).trimmingCharacters(in: .whitespacesAndNewlines)

      state = .expectingKey
      return .value(result.unquoted())
    case .end:
      return nil
    }
  }

  private mutating func skip (_ skipSet: CharacterSet) {
    remaining = remaining.drop(while: { skipSet.contains($0) })
    if remaining.isEmpty && state != .expectingValue {
      state = .end
    }
  }

  private mutating func error (_ error: ssh.ConfigParserError) -> Token {
    state = .end
    return .invalid(error)
  }

  enum State {

    case expectingKey
    case expectingValue
    case end
  }
}
