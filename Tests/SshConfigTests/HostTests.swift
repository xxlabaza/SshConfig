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
@testable import SshConfig

final class HostTests: XCTestCase {

  func testEquals () throws {
    let host = ssh.Host("github.com gitlab.com",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    )

    XCTAssertEqual(host, ssh.Host("github.com gitlab.com",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))
    XCTAssertEqual(host, ssh.Host("   github.com    gitlab.com    ",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))
    XCTAssertNotEqual(host, ssh.Host("github.com",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))
    XCTAssertNotEqual(host, ssh.Host("github.com gitlab.com",
      { $0.user = "artem" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))
  }

  func testPropertiesAccess () throws {
    let host = ssh.Host("github.com gitlab.com",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    )

    XCTAssertNotNil(host.properties.user)
    XCTAssertEqual(host.properties.user, "")

    XCTAssertNotNil(host.properties.identityFile)
    XCTAssertEqual(host.properties.identityFile, ["~/.ssh/id_ed25519"])

    XCTAssertNil(host.properties.port)
  }

  func testMatch () throws {
    let host = ssh.Host(" github.com *lab.com    pop? ",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    )

    XCTAssertTrue(host.match("github.com"))
    XCTAssertTrue(host.match("gitlab.com"))
    XCTAssertTrue(host.match("artlab.com"))
    XCTAssertTrue(host.match("popa"))

    XCTAssertFalse(host.match("popas"))
    XCTAssertFalse(host.match("gitlab.io"))
    XCTAssertFalse(host.match("example.com"))
  }
}
