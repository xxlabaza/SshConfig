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

final class TokenizerTests: XCTestCase {

  func testWholeIterator () throws {
    let content = """

    Host github.com  gitlab.com
      user=
      Identityfile ~/.ssh/id_ed25519

    Host myserv
      uSeR xxlabaza
      hostKeyAlias "  "

      proxyJump A,B,C , D , E,

      port 56


    Host *
     port      2020
       user popa
         addKeysToAgent no

    """

    var actualTokens: [Token] = []
    for token in Tokens(base: content) {
      actualTokens.append(token)
    }

    XCTAssertEqual(actualTokens, [
      .key("Host"),
      .value("github.com  gitlab.com"),
      .key("user"),
      .value(""),
      .key("Identityfile"),
      .value("~/.ssh/id_ed25519"),
      .key("Host"),
      .value("myserv"),
      .key("uSeR"),
      .value("xxlabaza"),
      .key("hostKeyAlias"),
      .value("  "),
      .key("proxyJump"),
      .value("A,B,C , D , E,"),
      .key("port"),
      .value("56"),
      .key("Host"),
      .value("*"),
      .key("port"),
      .value("2020"),
      .key("user"),
      .value("popa"),
      .key("addKeysToAgent"),
      .value("no")
    ])
  }

  func testBasicTokensChecks () throws {
    let content = """
    Host github.com gitlab.com
      user xxlabaza
    """

    let tokens = Tokens(base: content)
    var iterator = tokens.makeIterator()

    var token = iterator.next()
    XCTAssertNotNil(token)
    if case .key(let key) = token {
      XCTAssertEqual(key, "Host")
    } else {
      XCTFail()
    }

    token = iterator.next()
    XCTAssertNotNil(token)
    if case .value(let value) = token {
      XCTAssertEqual(value, "github.com gitlab.com")
    } else {
      XCTFail()
    }

    token = iterator.next()
    XCTAssertNotNil(token)
    if case .key(let key) = token {
      XCTAssertEqual(key, "user")
    } else {
      XCTFail()
    }

    token = iterator.next()
    XCTAssertNotNil(token)
    if case .value(let value) = token {
      XCTAssertEqual(value, "xxlabaza")
    } else {
      XCTFail()
    }
  }

  func testIllegalTokensDelimiter () throws {
    let content = "Key?value"
    let tokens = Tokens(base: content)
    var iterator = tokens.makeIterator()

    var token = iterator.next()
    XCTAssertNotNil(token)
    if case let .invalid(.illegalTokensDelimiter(key, delimiter)) = token {
      XCTAssertEqual(key, "Key")
      XCTAssertEqual(delimiter, "?")
    } else {
      XCTFail()
    }

    token = iterator.next()
    XCTAssertNil(token)
  }

  func testEmptyContent () throws {
    let content = ""
    let tokens = Tokens(base: content)
    var iterator = tokens.makeIterator()

    XCTAssertNil(iterator.next())
    XCTAssertNil(iterator.next())
  }

  func testEmptyKeyToken () throws {
    for content in ["\"\"", "\"  \"", "\"  \" value", "= value"] {
      let tokens = Tokens(base: content)
      var iterator = tokens.makeIterator()

      var token = iterator.next()
      XCTAssertNotNil(token)
      guard case .invalid(.emptyKeyToken) = token else {
        XCTFail()
        return
      }

      token = iterator.next()
      XCTAssertNil(token)
    }
  }

  func testEmptyValueToken () throws {
    let content = "Key"
    let tokens = Tokens(base: content)
    var iterator = tokens.makeIterator()

    var token = iterator.next()
    XCTAssertNotNil(token)
    if case .key(let key) = token {
      XCTAssertEqual(key, "Key")
    } else {
      XCTFail()
    }

    token = iterator.next()
    guard case .invalid(.emptyValueToken) = token else {
      XCTFail()
      return
    }

    token = iterator.next()
    XCTAssertNil(token)
  }
}
