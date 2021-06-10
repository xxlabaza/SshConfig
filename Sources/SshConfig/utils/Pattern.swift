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

struct Pattern: Equatable {

  static func from (wildcard string: String) -> Pattern {
    let escapedString = NSRegularExpression.escapedPattern(for: string)
    let patternString = escapedString
      .replacingOccurrences(of: "\\*", with: ".*")
      .replacingOccurrences(of: "\\?", with: ".")

    return Pattern("^\(patternString)$")
  }

  private let regex: NSRegularExpression
  let string: String

  init (_ pattern: String) {
    regex = try! NSRegularExpression(pattern: pattern)
    string = regex.pattern
  }

  func matcher (_ string: String) -> Matcher {
    let stringRange = NSRange(
      string.startIndex..<string.endIndex,
      in: string
    )
    let matches = regex.matches(
      in: string,
      range: stringRange
    )
    return Matcher(string: string, matches: matches)
  }

  struct Matcher {

    private let optionalMatch: NSTextCheckingResult?
    private let originalString: String

    fileprivate init (string: String, matches: [NSTextCheckingResult]) {
      originalString = string
      optionalMatch = matches.first
    }

    func matches () -> Bool {
      return optionalMatch != nil
    }

    func group (name: String) -> String? {
      guard let match = optionalMatch else {
        return nil
      }

      let matchRange = match.range(withName: name)
      guard let substringRange = Range(matchRange, in: originalString) else {
        return nil
      }

      return String(originalString[substringRange])
    }
  }
}
