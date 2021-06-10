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

@propertyWrapper
public struct NoneAsNil<Wrapped> {

  public var wrappedValue: Wrapped?

  var isNone: Bool {
    if let string = wrappedValue as? String, string == "none" {
      return true
    }
    return false
  }

  public init (wrappedValue: Wrapped?) {
    self.wrappedValue = wrappedValue
  }
}

extension NoneAsNil: Encodable where Wrapped: Encodable {

  public func encode (to encoder: Encoder) throws {
    // try wrappedValue.encode(to: encoder)
  }
}

extension NoneAsNil: Decodable where Wrapped: Decodable {

  public init (from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    let string = try container.decode(String.self)
    if string == "none" {
      wrappedValue = nil
      return
    }

    wrappedValue = container.decodeNil()
                   ? try container.decode(Wrapped.self)
                   : nil
  }
}

extension NoneAsNil: Equatable where Wrapped: Equatable {

  public static func == (left: NoneAsNil, right: NoneAsNil) -> Bool {
    return (left.isNone && right.isNone) ||
           (left.isNone && right.wrappedValue == nil) ||
           (left.wrappedValue == nil && right.isNone) ||
           (left.wrappedValue == right.wrappedValue)
  }
}

extension KeyedEncodingContainer {

  mutating func encode<Wrapped> (_ value: NoneAsNil<Wrapped>, forKey key: K)
  throws where Wrapped: Encodable {
    if value.isNone {
      try encode("none", forKey: key)
      return
    }
    guard let wrappedValue = value.wrappedValue else {
      return
    }
    try encode(wrappedValue, forKey: key)
  }
}

extension KeyedDecodingContainer {

  public func decode<Wrapped> (_ type: NoneAsNil<Wrapped>.Type,
                               forKey key: KeyedDecodingContainer<K>.Key)
  throws -> NoneAsNil<Wrapped> where Wrapped: Decodable {
    let result = try decodeIfPresent(NoneAsNil<Wrapped>.self, forKey: key)
    return result ?? NoneAsNil<Wrapped>(wrappedValue: nil)
  }
}
