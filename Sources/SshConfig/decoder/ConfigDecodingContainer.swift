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

struct ConfigDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

  let context: DecodingContext
  let rootDecoder: Decoder

  var codingPath: [CodingKey] {
    return context.codingPath
  }

  var allKeys: [Key] {
    return context.allKeys.map { Key(stringValue: $0)! }
  }

  init (for context: DecodingContext, rootDecoder: Decoder) {
    self.context = context
    self.rootDecoder = rootDecoder
  }

  func contains (_ key: Key) -> Bool {
    return context[key] != nil
  }

  func decodeNil (forKey key: Key) throws -> Bool {
    return contains(key) == false
  }

  func decode (_ type: Bool.Type, forKey key: Key) throws -> Bool {
    guard let string = context[key] else {
      throw ssh.ConfigDecoderError.noValueToDecode(forKey: key.stringValue)
    }

    let lower = string.lowercased()
    switch lower {
    case "yes":
      return true
    case "no":
      return false
    default:
      return Bool(lower)!
    }
  }

  func decode (_ type: String.Type, forKey key: Key) throws -> String {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Double.Type, forKey key: Key) throws -> Double {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Float.Type, forKey key: Key) throws -> Float {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Int.Type, forKey key: Key) throws -> Int {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: UInt.Type, forKey key: Key) throws -> UInt {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    return try singleValueDecode(type, for: key)
  }

  func decode (_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    return try singleValueDecode(type, for: key)
  }

  func decode<T> (_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    try context.push(.decodable(key, type))
    defer {
      try! context.pop()
    }
    return try T(from: rootDecoder)
  }

  func nestedContainer<NestedKey> (keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    throw try creteUnableToDecode(key: key.stringValue, for: type)
  }

  func nestedUnkeyedContainer (forKey key: Key) throws -> UnkeyedDecodingContainer {
    throw try creteUnableToDecode(key: key.stringValue, for: AnyObject.self)
  }

  func superDecoder () throws -> Decoder {
    return rootDecoder
  }

  func superDecoder (forKey key: Key) throws -> Decoder {
    return rootDecoder
  }

  private func singleValueDecode<T> (_ type: T.Type, for key: Key) throws -> T where T : Decodable {
    try context.push(.primitive(key, type))
    defer {
      try! context.pop()
    }
    return try T(from: rootDecoder)
  }

  private func creteUnableToDecode (key: String, for type: Any.Type) throws -> ssh.ConfigDecoderError {
    let value = try context.getCurrentValue() ?? "<no_value>"
    return ssh.ConfigDecoderError.unableToDecode(path: key, value: value, as: type)
  }
}
