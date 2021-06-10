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

class DecodingContext {

  private static func toName (_ key: CodingKey) -> String {
    return key.stringValue.lowercased()
  }

  private let parsedProperties: [String: [String]]
  private var stack: [InternalCurrentDecodingContext] = []
  private(set) var parsedPropertyNames: Set<String> = []

  var codingPath: [CodingKey] {
    return stack.map { it in
      switch it {
      case let .primitive(key, _, _):
        return key
      case let .array(key, _, _):
        return key
      case let .dictionary(key, _, _):
        return key
      case let .decodable(key, _, _):
        return key
      }
    }
  }

  var allKeys: [String] {
    guard case let .dictionary(_, _, values) = stack.last else {
      return []
    }
    return Array(values.keys)
  }

  init (_ parsedProperties: [String: [String]]) {
    self.parsedProperties = parsedProperties
  }

  func push (_ currentDecoding: CurrentDecoding) throws {
    let internalCurrentDecoding: InternalCurrentDecodingContext

    switch currentDecoding {
    case let .primitive(key, type):
      guard let value = self[key] else {
        throw ssh.ConfigDecoderError.noValueToDecode(forKey: key.stringValue)
      }
      internalCurrentDecoding = .primitive(key, type, value)

    case let .arrayElement(index, type):
      guard let peek = stack.last else {
        throw ssh.ConfigDecoderError.internalError("Unable to parse an array element at the root of context")
      }
      guard case let .array(key, _, values) = peek else {
        throw ssh.ConfigDecoderError.internalError("Parsing an array element with no array in context")
      }
      let value = values[index]
      internalCurrentDecoding = .decodable(key, type, value)

    case let .decodable(key, type) where "\(type)".hasPrefix("Dictionary<"):
      let values = getDictionaryValue(for: key)
      internalCurrentDecoding = .dictionary(key, type, values)

    case let .decodable(key, type) where "\(type)".hasPrefix("Array<"):
      guard let values = getValues(for: key) else {
        throw ssh.ConfigDecoderError.noValueToDecode(forKey: key.stringValue)
      }
      internalCurrentDecoding = .array(key, type, values)

    case let .decodable(key, type) where "\(key)".hasPrefix("_DictionaryCodingKey"):
      guard let peek = stack.last else {
        throw ssh.ConfigDecoderError.internalError("Unable to parse a dictionary key at the root of context")
      }
      guard case let .dictionary(_, _, values) = peek else {
        throw ssh.ConfigDecoderError.internalError("Parsing a dictionary key with no dictionary in context")
      }
      guard let value = values[key.stringValue] else {
        throw ssh.ConfigDecoderError.noValueToDecode(forKey: key.stringValue)
      }
      internalCurrentDecoding = .decodable(key, type, value)

    case let .decodable(key, type):
      guard let value = self[key] else {
        throw ssh.ConfigDecoderError.noValueToDecode(forKey: key.stringValue)
      }
      internalCurrentDecoding = .decodable(key, type, value)
    }

    stack.append(internalCurrentDecoding)
  }

  func pop () throws {
    if stack.count <= 0 {
      throw ssh.ConfigDecoderError.internalError("Unable to 'pop', stack is empty")
    }
    _ = stack.removeLast()
  }

  func getCurrentValue () throws -> String? {
    switch stack.last {
    case let .primitive(_, _, value):
      return value
    case let .decodable(_, _, value):
      return value
    default:
      return nil
    }
  }

  func getCurrentValues () throws -> [String]? {
    switch stack.last {
    case let .array(_, _, values):
      return values
    default:
      return nil
    }
  }

  subscript (index: CodingKey) -> String? {
    return getValues(for: index)?.last
  }

  private func getValues (for key: CodingKey) -> [String]? {
    let name = DecodingContext.toName(key)
    guard let values = parsedProperties[name] else {
      return nil
    }
    parsedPropertyNames.insert(name)

    guard let separator = ssh.Properties.delimiter(for: name) else {
      return values
    }
    return values.last!.components(separatedBy: separator)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0.isEmpty == false }
  }

  private func getDictionaryValue (for key: CodingKey) -> [String: String] {
    guard let values = getValues(for: key) else {
      return [:]
    }

    let pairsWithDuplicateKeys = values
      .map { $0
        .split(maxSplits: 1, whereSeparator: { $0 == " " || $0 == "=" })
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { $0.isEmpty == false }
      }
      .filter { $0.count == 2 }
      .map { ($0[0], $0[1]) }

    return Dictionary(pairsWithDuplicateKeys,
                      uniquingKeysWith: { (_, last) in last })
  }

  enum CurrentDecoding {

    case primitive(_ key: CodingKey, _ type: Any.Type)
    case arrayElement(_ index: Int, _ type: Any.Type)
    case decodable(_ key: CodingKey, _ type: Any.Type)
  }

  enum InternalCurrentDecodingContext {

    case primitive(_ key: CodingKey, _ type: Any.Type, _ value: String)
    case array(_ key: CodingKey, _ type: Any.Type, _ values: [String])
    case dictionary(_ key: CodingKey, _ type: Any.Type, _ values: [String: String])
    case decodable(_ key: CodingKey, _ type: Any.Type, _ value: String)
  }
}
