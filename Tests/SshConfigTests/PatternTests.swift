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

final class PatternTests: XCTestCase {

  func testNamedGroupsWithPort () throws {
    let pattern = Pattern(#"^(?<user>.+)@(?<host>[^:\n]+)(:(?<port>\d+))?$"#);
    let matcher = pattern.matcher("xxlabaza@example.com:89")
    XCTAssertTrue(matcher.matches())

    let username = try XCTUnwrap(matcher.group(name: "user"))
    XCTAssertEqual(username, "xxlabaza")

    let hostname = try XCTUnwrap(matcher.group(name: "host"))
    XCTAssertEqual(hostname, "example.com")

    let port = try XCTUnwrap(matcher.group(name: "port"))
    XCTAssertEqual(port, "89")
  }

  func testNamedGroupsWithoutPort () throws {
    let pattern = Pattern(#"^(?<user>.+)@(?<host>[^:\n]+)(:(?<port>\d+))?$"#);
    let matcher = pattern.matcher("xxlabaza@example.com")
    XCTAssertTrue(matcher.matches())

    let username = try XCTUnwrap(matcher.group(name: "user"))
    XCTAssertEqual(username, "xxlabaza")

    let hostname = try XCTUnwrap(matcher.group(name: "host"))
    XCTAssertEqual(hostname, "example.com")

    XCTAssertNil(matcher.group(name: "port"))
  }

  func testWildcardExact () throws {
    let pattern = Pattern.from(wildcard: "192.168.0.1")

    XCTAssertTrue(pattern.matcher("192.168.0.1").matches())
    XCTAssertFalse(pattern.matcher("192.168.0.2").matches())
    XCTAssertFalse(pattern.matcher("192.168.0z1").matches())
  }

  func testWildcardZeroOrMoreCharacters () throws {
    let pattern = Pattern.from(wildcard: "192.*.0.1")

    XCTAssertTrue(pattern.matcher("192.168.0.1").matches())
    XCTAssertFalse(pattern.matcher("192.168.0.2").matches())
    XCTAssertTrue(pattern.matcher("192.0.0.1").matches())
  }

  func testWildcardExactlyOneCharacter () throws {
    let pattern = Pattern.from(wildcard: "192.168.0.?")

    XCTAssertTrue(pattern.matcher("192.168.0.1").matches())
    XCTAssertTrue(pattern.matcher("192.168.0.2").matches())
    XCTAssertFalse(pattern.matcher("192.168.0.12").matches())
    XCTAssertFalse(pattern.matcher("192.0.0.1").matches())
  }
}
