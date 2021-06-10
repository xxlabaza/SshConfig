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

final class ConfigParserTests: XCTestCase {

  func testExample () throws {
    let content = """

    Host github.com  gitlab.com
      user=
      Identityfile ~/.ssh/id_ed25519
      SetEnv FOO=bar
        setenv LANG C

    Host myserv
      uSeR xxlabaza
      hostKeyAlias "  "

      proxyJump A,B,C , D , E,

      port 56


    Host *
     port      2020
       user popa
         addKeysToAgent no
    LocalForward 5901 computer.myHost.edu:5901

    """

    let parser = ssh.ConfigParser()
    let config = try parser.parse(content)

    XCTAssertEqual(config.count, 3)

    let (alias1, properties1) = config[0]
    XCTAssertEqual(alias1, "github.com  gitlab.com")
    XCTAssertEqual(alias1.toTokens(), ["github.com", "gitlab.com"])
    XCTAssertEqual(properties1.count, 3)
    XCTAssertUnwrapEqual(properties1["user"], [""])
    XCTAssertUnwrapEqual(properties1["identityfile"], ["~/.ssh/id_ed25519"])
    XCTAssertUnwrapEqual(properties1["setenv"], ["FOO=bar", "LANG C"])

    let (alias2, properties2) = config[1]
    XCTAssertEqual(alias2, "myserv")
    XCTAssertEqual(properties2.count, 4)
    XCTAssertUnwrapEqual(properties2["user"], ["xxlabaza"])
    XCTAssertUnwrapEqual(properties2["hostkeyalias"], ["  "])
    XCTAssertUnwrapEqual(properties2["proxyjump"], ["A,B,C , D , E,"])
    XCTAssertUnwrapEqual(properties2["port"], ["56"])

    let (alias3, properties3) = config[2]
    XCTAssertEqual(alias3, "*")
    XCTAssertEqual(properties3.count, 4)
    XCTAssertUnwrapEqual(properties3["port"], ["2020"])
    XCTAssertUnwrapEqual(properties3["user"], ["popa"])
    XCTAssertUnwrapEqual(properties3["addkeystoagent"], ["no"])
    XCTAssertUnwrapEqual(properties3["localforward"], ["5901 computer.myHost.edu:5901"])
  }

  func testEmptyKeyToken () throws {
    var error: Error!

    var content = """
    Host popa
      =user
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .emptyKeyToken)

    content = """
    Host popa
      "" user
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .emptyKeyToken)

    content = """
    Host popa
      "  " user
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .emptyKeyToken)

    content = """
    Host popa
      "  "=user
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .emptyKeyToken)
  }

  func testEmptyValueToken () throws {
    let content = """
    Host popa
      user
    """
    var error: Error!

    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .emptyValueToken)
  }

  func testIllegalTokensDelimiter () throws {
    var error: Error!

    var content = """
    Host popa
      user?xxlabaza
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .illegalTokensDelimiter(after: "user", delimiter: "?"))

    content = """
    Host popa
      user
      xxlabaza
    """
    XCTAssertThrowsError(try ssh.ConfigParser().parse(content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .illegalTokensDelimiter(after: "user", delimiter: "\n"))
  }

  func testUnexpectedToken () throws {
    var error: Error!

    XCTAssertThrowsError(try ssh.ConfigParser().parse("host")) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .unexpectedToken("key(\"host\")"))
  }

  func testNoAliasesForHost () throws {
    var error: Error!

    XCTAssertThrowsError(try ssh.ConfigParser().parse("Host \" \"")) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .noAliasForHost)
  }

  func testNoPropertiesForHost () throws {
    var error: Error!

    XCTAssertThrowsError(try ssh.ConfigParser().parse("Host Host")) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .noPropertiesForHost)

    XCTAssertThrowsError(try ssh.ConfigParser().parse("Host popa")) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigParserError)
    XCTAssertEqual(error as? ssh.ConfigParserError, .noPropertiesForHost)
  }

  private func XCTAssertUnwrapEqual <T> (_ actual: T?, _ expected: T) where T: Equatable {
    XCTAssertNotNil(actual)
    XCTAssertEqual(actual!, expected)
  }
}
