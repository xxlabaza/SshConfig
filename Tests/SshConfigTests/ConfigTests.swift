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

import XCTest
import SshConfig

final class ConfigTests: XCTestCase {

  func testHostsAccess () throws {
    let config = ssh.Config(
      ssh.Host("github.com gitlab.com",
        { $0.user = "" },
        { $0.identityFile = ["~/.ssh/id_ed25519"] }
      ),
      ssh.Host("myserv",
        { $0.port = 56 },
        { $0.user = "xxlabaza" },
        { $0.hostKeyAlias = "  " },
        { $0.proxyJump = ["A", "B", "C", "D", "E"] }
      ),
      ssh.Host("*",
        { $0.port = 2020 },
        { $0.user = "popa" },
        { $0.addKeysToAgent = .no },
        { $0.forwardX11Timeout = ssh.TimeFormat(days: 1, seconds: 15) }
      )
    )

    XCTAssertEqual(config.hosts[0].alias, "github.com gitlab.com")
    XCTAssertEqual(config.hosts[1].alias, "myserv")
    XCTAssertEqual(config.hosts[2].alias, "*")

    XCTAssertEqual(config.hosts[0], ssh.Host("github.com gitlab.com",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))
  }
}
