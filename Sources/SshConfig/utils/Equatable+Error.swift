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

extension Equatable where Self : Error {

  public static func == (left: Self, right: Self) -> Bool {
    guard type(of: left) == type(of: right) else {
      return false
    }
    let error1 = left as NSError
    let error2 = right as NSError
    return error1.domain == error2.domain &&
          error1.code == error2.code &&
          "\(left)" == "\(right)"
  }
}
