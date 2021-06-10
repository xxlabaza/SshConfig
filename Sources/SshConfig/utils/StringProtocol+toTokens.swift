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

  func toTokens (delimiter: String = " ") -> [String] {
    return components(separatedBy: delimiter)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { $0.isEmpty == false }
  }
}
