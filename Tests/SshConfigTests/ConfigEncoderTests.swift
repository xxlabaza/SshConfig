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

final class ConfigEncoderTests: XCTestCase {

  func testSimple () throws {
    let expected = """
    Host github.com gitlab.com
      IdentityFile ~/.ssh/id_ed25519
      User ""
    Host myserv
      HostKeyAlias "  "
      Port 56
      ProxyJump A,B,C,D,E
      User xxlabaza
    Host *
      AddKeysToAgent no
      Port 2020
      User popa
    """

    let actual = try ssh.ConfigEncoder().encode(ssh.Config(
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
        { $0.addKeysToAgent = .no }
      )
    ))

    XCTAssertEqual(actual, expected)
  }

  func testEncodeUparsed () throws {
    let expected = """
    Host myserv
      Port 2021
      UnKnOwN1 123
      Unknown2 Hello world
      Unknown2 How are you?
      User admin
    """

    let actual = try ssh.ConfigEncoder().encode(ssh.Config(
      ssh.Host("myserv",
        { $0.user = "admin" },
        { $0.port = 2021 },
        { $0.unparsed = [
          "Unknown2": ["Hello world", "How are you?"],
          "UnKnOwN1": ["123"]
        ] }
      )
    ))

    XCTAssertEqual(actual, expected)
  }

  func testEncodeSendEnv () throws {
    let expected = """
    Host myserv
      Port 2021
      SendEnv POPA1
      SendEnv POPA2
      User admin
    """

    let actual = try ssh.ConfigEncoder().encode(ssh.Config(
      ssh.Host("myserv",
        { $0.user = "admin" },
        { $0.port = 2021 },
        { $0.sendEnv = ["POPA1", "POPA2"] }
      )
    ))

    XCTAssertEqual(actual, expected)
  }

  func testEncodeSetEnv () throws {
    let expected = """
    Host myserv
      Port 2021
      SetEnv POPA1=1
      SetEnv POPA2=2
      User admin
    """

    let actual = try ssh.ConfigEncoder().encode(ssh.Config(
      ssh.Host("myserv",
        { $0.user = "admin" },
        { $0.port = 2021 },
        { $0.setEnv = [
          "POPA1": "1",
          "POPA2": "2"
        ] }
      )
    ))

    XCTAssertEqual(actual, expected)
  }
}
