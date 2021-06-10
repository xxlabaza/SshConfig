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

extension StringProtocol {

  var isHex: Bool {
    return hasPrefix("0x")
  }
  var isBinary: Bool {
    return hasPrefix("0b")
  }
  var isOctal: Bool {
    return (hasPrefix("0") && count > 1) || hasPrefix("0o")
  }

  var dropHexPrefix: SubSequence {
    return isHex ? dropFirst(2) : self[...]
  }
  var dropBinaryPrefix: SubSequence {
    return isBinary ? dropFirst(2) : self[...]
  }
  var dropOctalPrefix: SubSequence {
    return isOctal ? dropFirst(1) : self[...]
  }

  var hexToDecimal: Int {
    return Int(dropHexPrefix, radix: 16) ?? 0
  }
  var binaryToDecimal: Int {
    return Int(dropBinaryPrefix, radix: 2) ?? 0
  }
  var octalToDecimal: Int {
    return Int(dropOctalPrefix, radix: 8) ?? 0
  }
}
