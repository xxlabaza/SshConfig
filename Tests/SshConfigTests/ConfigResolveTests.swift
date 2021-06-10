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

final class ConfigResolveTests: XCTestCase {

  func testSimpleConfig () throws {
    let config = try ssh.ConfigDecoder().decode(from: """
      Host myser?
        port 2021
        user ZadirA
    """)

    let properties1 = config.resolve(for: "myserv")
    XCTAssertEqual(properties1.port, 2021)
    XCTAssertEqual(properties1.user, "ZadirA")
    XCTAssertEqual(properties1.addressFamily, .any)

    let properties2 = config.resolve(for: "myserA")
    XCTAssertEqual(properties2.port, 2021)
    XCTAssertEqual(properties2.user, "ZadirA")
    XCTAssertEqual(properties2.addressFamily, .any)

    let properties3 = config.resolve(for: "google.com")
    XCTAssertEqual(properties3.port, 22)
    XCTAssertNil(properties3.user)
    XCTAssertEqual(properties3.addressFamily, .any)
  }

  func testResolveOrder () throws {
    let config = ssh.Config(
      ssh.Host("github.com  gitlab.com",
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

    let properties = config.resolve(for: "myserv")
    XCTAssertEqual(properties.port, 56)
    XCTAssertEqual(properties.user, "xxlabaza")
    XCTAssertEqual(properties.hostKeyAlias, "  ")
    XCTAssertEqual(properties.proxyJump, ["A", "B", "C", "D", "E"])
    XCTAssertEqual(properties.addKeysToAgent, .no)
    XCTAssertEqual(properties.forwardX11Timeout, ssh.TimeFormat(days: 1, seconds: 15))
    XCTAssertEqual(properties.identityFile, [
      "~/.ssh/id_dsa",
      "~/.ssh/id_ecdsa",
      "~/.ssh/id_ecdsa_sk",
      "~/.ssh/id_ed25519",
      "~/.ssh/id_ed25519_sk",
      "~/.ssh/id_rsa"
    ])
  }

  func testWildcardConfig () throws {
    let config = try ssh.ConfigDecoder().decode(from: """
      Host my*
        port 2021
        user ZadirA
    """)

    let properties1 = config.resolve(for: "myserv")
    XCTAssertEqual(properties1.port, 2021)
    XCTAssertEqual(properties1.user, "ZadirA")
    XCTAssertEqual(properties1.addressFamily, .any)

    let properties2 = config.resolve(for: "_myserv")
    XCTAssertEqual(properties2.port, 22)
    XCTAssertNil(properties2.user)
    XCTAssertEqual(properties2.addressFamily, .any)
  }

  func testInternalAliasesPattern_All () throws {
    let host = ssh.Host("*")

    XCTAssertTrue(host.aliasAsPattern.matcher("gitlab.com").matches())
    XCTAssertTrue(host.aliasAsPattern.matcher("popa.com").matches())
  }

  func testInternalAliasesPattern_SpecificHost () throws {
    let host = ssh.Host("popa.com")

    XCTAssertFalse(host.aliasAsPattern.matcher("gitlab.com").matches())
    XCTAssertTrue(host.aliasAsPattern.matcher("popa.com").matches())
  }

  func testInternalAliasesPattern_SpecificHosts () throws {
    let host = ssh.Host("github.com  gitlab.com")

    XCTAssertTrue(host.aliasAsPattern.matcher("github.com").matches())
    XCTAssertTrue(host.aliasAsPattern.matcher("gitlab.com").matches())
    XCTAssertFalse(host.aliasAsPattern.matcher("popa.com").matches())
  }

  func testInternalAliasesPattern_SpecificAlias () throws {
    let host = ssh.Host("popa")

    XCTAssertFalse(host.aliasAsPattern.matcher("myserv").matches())
    XCTAssertTrue(host.aliasAsPattern.matcher("popa").matches())
  }

  func testInternalAliasesPattern_SpecificAliases () throws {
    let host = ssh.Host("myserv popa")

    XCTAssertTrue(host.aliasAsPattern.matcher("myserv").matches())
    XCTAssertTrue(host.aliasAsPattern.matcher("popa").matches())
    XCTAssertFalse(host.aliasAsPattern.matcher("another").matches())
  }
}
