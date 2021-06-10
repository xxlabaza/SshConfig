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

class ConfigUnkeyedDecodingContainer: UnkeyedDecodingContainer {

  let context: DecodingContext
  let rootDecoder: Decoder

  var currentIndex: Int = 0

  var codingPath: [CodingKey] {
    return context.codingPath
  }

  var count: Int? {
    return try! context.getCurrentValues()?.count
  }

  var isAtEnd: Bool {
    return currentIndex >= count!
  }

  init (for context: DecodingContext, rootDecoder: Decoder) {
    self.context = context
    self.rootDecoder = rootDecoder
  }

  func decodeNil () throws -> Bool {
    return false
  }

  func decode (_ type: Bool.Type) throws -> Bool {
    return try decodeMe(type)
  }

  func decode (_ type: String.Type) throws -> String {
    return try decodeMe(type)
  }

  func decode (_ type: Double.Type) throws -> Double {
    return try decodeMe(type)
  }

  func decode (_ type: Float.Type) throws -> Float {
    return try decodeMe(type)
  }

  func decode (_ type: Int.Type) throws -> Int {
    return try decodeMe(type)
  }

  func decode (_ type: Int8.Type) throws -> Int8 {
    return try decodeMe(type)
  }

  func decode (_ type: Int16.Type) throws -> Int16 {
    return try decodeMe(type)
  }

  func decode (_ type: Int32.Type) throws -> Int32 {
    return try decodeMe(type)
  }

  func decode (_ type: Int64.Type) throws -> Int64 {
    return try decodeMe(type)
  }

  func decode (_ type: UInt.Type) throws -> UInt {
    return try decodeMe(type)
  }

  func decode (_ type: UInt8.Type) throws -> UInt8 {
    return try decodeMe(type)
  }

  func decode (_ type: UInt16.Type) throws -> UInt16 {
    return try decodeMe(type)
  }

  func decode (_ type: UInt32.Type) throws -> UInt32 {
    return try decodeMe(type)
  }

  func decode (_ type: UInt64.Type) throws -> UInt64 {
    return try decodeMe(type)
  }

  func decode<T> (_ type: T.Type) throws -> T where T : Decodable {
    return try decodeMe(type)
  }

  func nestedContainer<NestedKey> (keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    throw try creteUnableToDecode(for: type)
  }

  func nestedUnkeyedContainer () throws -> UnkeyedDecodingContainer {
    throw try creteUnableToDecode(for: AnyObject.self)
  }

  func superDecoder () throws -> Decoder {
    return rootDecoder
  }

  func decodeMe<T> (_ type: T.Type) throws -> T where T : Decodable {
    try context.push(.arrayElement(currentIndex, type))
    currentIndex += 1
    defer {
      try! context.pop()
    }
    return try T(from: rootDecoder)
  }

  private func creteUnableToDecode (for type: Any.Type) throws -> ssh.ConfigDecoderError {
    let key = codingPath
      .map { $0.stringValue }
      .joined(separator: "/")

    let value: String
    if let values = try context.getCurrentValues() {
      value = values[currentIndex]
    } else {
      value = "<no_value>"
    }

    return ssh.ConfigDecoderError.unableToDecode(path: key, value: value, as: type)
  }
}
