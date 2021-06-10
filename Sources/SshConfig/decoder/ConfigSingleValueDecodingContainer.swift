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

struct ConfigSingleValueDecodingContainer: SingleValueDecodingContainer {

  let context: DecodingContext
  let rootDecoder: Decoder

  var codingPath: [CodingKey] {
    return context.codingPath
  }

  init (for context: DecodingContext, rootDecoder: Decoder) {
    self.context = context
    self.rootDecoder = rootDecoder
  }

  func decodeNil () -> Bool {
    return try! context.getCurrentValue() != nil
  }

  func decode (_ type: Bool.Type) throws -> Bool {
    guard let string = try context.getCurrentValue() else {
      throw ssh.ConfigDecoderError.noValueToDecode()
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

  func decode (_ type: String.Type) throws -> String {
    guard let string = try context.getCurrentValue() else {
      throw ssh.ConfigDecoderError.noValueToDecode()
    }
    return string
  }

  func decode (_ type: Double.Type) throws -> Double {
    return try decodeMe(Double.self)
  }

  func decode (_ type: Float.Type) throws -> Float {
    return try decodeMe(Float.self)
  }

  func decode (_ type: Int.Type) throws -> Int {
    return try decodeMe(Int.self)
  }

  func decode (_ type: Int8.Type) throws -> Int8 {
    return try decodeMe(Int8.self)
  }

  func decode (_ type: Int16.Type) throws -> Int16 {
    return try decodeMe(Int16.self)
  }

  func decode (_ type: Int32.Type) throws -> Int32 {
    return try decodeMe(Int32.self)
  }

  func decode (_ type: Int64.Type) throws -> Int64 {
    return try decodeMe(Int64.self)
  }

  func decode (_ type: UInt.Type) throws -> UInt {
    return try decodeMe(UInt.self)
  }

  func decode (_ type: UInt8.Type) throws -> UInt8 {
    return try decodeMe(UInt8.self)
  }

  func decode (_ type: UInt16.Type) throws -> UInt16 {
    return try decodeMe(UInt16.self)
  }

  func decode (_ type: UInt32.Type) throws -> UInt32 {
    return try decodeMe(UInt32.self)
  }

  func decode (_ type: UInt64.Type) throws -> UInt64 {
    return try decodeMe(UInt64.self)
  }

  func decode<T> (_ type: T.Type) throws -> T where T : Decodable {
    return try T(from: rootDecoder)
  }

  private func decodeMe<T> (_ type: T.Type) throws -> T where T: LosslessStringConvertible {
    guard let string = try context.getCurrentValue() else {
      throw ssh.ConfigDecoderError.noValueToDecode()
    }
    guard let result = T(string) else {
      throw try creteUnableToDecode(value: string, for: T.self)
    }
    return result
  }

  private func decodeMe<T> (_ type: T.Type) throws -> T where T: FixedWidthInteger {
    guard let string = try context.getCurrentValue() else {
      throw ssh.ConfigDecoderError.noValueToDecode()
    }

    let (value, radix): (String, Int)
    if string.isHex {
      (value, radix) = (String(string.dropHexPrefix), 16)
    } else if string.isOctal {
      (value, radix) = (String(string.dropOctalPrefix), 8)
    } else if string.isBinary {
      (value, radix) = (String(string.dropBinaryPrefix), 2)
    } else {
      (value, radix) = (string, 10)
    }

    guard let result = T(value, radix: radix) else {
      throw try creteUnableToDecode(value: string, for: T.self)
    }
    return result
  }

  private func creteUnableToDecode (value: String, for type: Any.Type) throws -> ssh.ConfigDecoderError {
    let key = codingPath
      .map { $0.stringValue }
      .joined(separator: "/")

    return ssh.ConfigDecoderError.unableToDecode(path: key, value: value, as: type)
  }
}
