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

final class UsageExample: XCTestCase {

  func testExample () throws {
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

    let json = try config.toJsonString()
    XCTAssertFalse(json.isEmpty)

    let decoded = try ssh.Config.from(json: json)
    XCTAssertEqual(config, decoded)
    XCTAssertEqual(properties, decoded.resolve(for: "myserv"))

    XCTAssertEqual(try config.toString(), """
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
      ForwardX11Timeout 1d15s
      Port 2020
      User popa
    """)

    XCTAssertEqual(config.hosts.count, 3)
    XCTAssertEqual(config.hosts[0], ssh.Host("   github.com   gitlab.com ",
      { $0.user = "" },
      { $0.identityFile = ["~/.ssh/id_ed25519"] }
    ))

    XCTAssertNotNil(config.hosts[0].properties.user)
    XCTAssertEqual(config.hosts[0].properties.user, "")
    XCTAssertNotNil(config.hosts[0].properties.identityFile)
    XCTAssertEqual(config.hosts[0].properties.identityFile, ["~/.ssh/id_ed25519"])
    XCTAssertNil(config.hosts[0].properties.port)
  }

  func testReadme1 () throws {
    let filePath = NSTemporaryDirectory() + "ssh_config"
    defer {
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: filePath) {
        try! fileManager.removeItem(atPath: filePath)
      }
    }

    try """
    Host gitlab.com github.com
      PreferredAuthentications publickey
      IdentityFile ~/.ssh/id_rsa
      User xxlabaza

    Host my*
      User admin
      Port 2021

    Host *
      SetEnv POPA=3000
    """.write(
      toFile: filePath,
      atomically: true,
      encoding: String.Encoding.utf8
    )

    let config = try! ssh.Config.load(path: filePath)

    let github = config.resolve(for: "github.com")
    assert(github.preferredAuthentications == [.publickey])
    assert(github.identityFile == ["~/.ssh/id_rsa"])
    assert(github.user == "xxlabaza")
    assert(github.setEnv == ["POPA": "3000"]) // from 'Host *'
    assert(github.port == 22) // the default one

    // github.com and gitlab.com resolve the same
    assert(github == config.resolve(for: "gitlab.com"))

    let myserver = config.resolve(for: "myserver")
    assert(myserver.user == "admin")
    assert(myserver.port == 2021)
    assert(myserver.setEnv == ["POPA": "3000"]) // from 'Host *'

    let backend = config.resolve(for: "backend")
    assert(backend.user == nil) // the default one
    assert(backend.port == 22) // the default one
    assert(backend.setEnv == ["POPA": "3000"]) // from 'Host *'
  }

  func testReadme2 () throws {
    let config = ssh.Config(
      ssh.Host("gitlab.com github.com",
        { $0.preferredAuthentications = [.publickey] },
        { $0.identityFile = ["~/.ssh/id_rsa"] },
        { $0.user = "xxlabaza" }
      ),
      ssh.Host("my*",
        { $0.user = "admin" },
        { $0.port = 2021 }
      ),
      ssh.Host("*",
        { $0.setEnv = ["POPA": "3000"] }
      )
    )

    let github = config.resolve(for: "github.com")
    assert(github.preferredAuthentications == [.publickey])
    assert(github.identityFile == ["~/.ssh/id_rsa"])
    assert(github.user == "xxlabaza")
    assert(github.setEnv == ["POPA": "3000"]) // from 'Host *'
    assert(github.port == 22) // the default one

    // github.com and gitlab.com resolve the same
    assert(github == config.resolve(for: "gitlab.com"))

    let myserver = config.resolve(for: "myserver")
    assert(myserver.user == "admin")
    assert(myserver.port == 2021)
    assert(myserver.setEnv == ["POPA": "3000"]) // from 'Host *'

    let backend = config.resolve(for: "backend")
    assert(backend.user == nil) // the default one
    assert(backend.port == 22) // the default one
    assert(backend.setEnv == ["POPA": "3000"]) // from 'Host *'
  }

  func testConfigParser () throws {
    let content = """
    Host myserv
      User alice
      Port 2021
    """

    let parser = ssh.ConfigParser()
    let parsedConfig = try parser.parse(content)
    assert(parsedConfig.count == 1)

    let (host, properties) = parsedConfig[0]
    assert(host == "myserv")
    assert(properties["user"] == ["alice"])
    assert(properties["port"] == ["2021"])
  }

  func testEncoder () throws {
    let config = ssh.Config(
      ssh.Host("myserv",
        { $0.user = "alice" },
        { $0.port = 2021 }
      )
    )

    let encoder = ssh.ConfigEncoder()
    let string = try encoder.encode(config)

    assert(string == """
    Host myserv
      Port 2021
      User alice
    """)
  }

  func testDecoder () throws {
    let content = """
    Host myserv
      User alice
      Port 2021
    """

    let decoder = ssh.ConfigDecoder()
    let config = try decoder.decode(from: content)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.user == "alice")
    assert(config.hosts[0].properties.port == 2021)
  }

  func testEmptyKeyToken () {
    let content = """
    Host myserv
      =user
      "" 2021
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch ssh.ConfigParserError.emptyKeyToken {
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testEmptyValueToken () {
    let content = """
    Host myserv
      user
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch ssh.ConfigParserError.emptyValueToken {
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testIllegalTokensDelimiter () {
    let content = """
    Host myserv
      user?xxlabaza
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch let ssh.ConfigParserError.illegalTokensDelimiter(after, delimiter) {
      assert(after == "user")
      assert(delimiter == "?")
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testUnexpectedToken () {
    let content = """
    host
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch let ssh.ConfigParserError.unexpectedToken(token) {
      assert(token == "key(\"host\")")
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testNoAliasForHost () {
    let content = """
    Host " "
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch ssh.ConfigParserError.noAliasForHost {
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testNoPropertiesForHost () {
    let content = """
    Host myserv
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigParser().parse(content)
    } catch ssh.ConfigParserError.noPropertiesForHost {
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testUnableToDecode () {
    let content = """
    Host *
      port abc
    """

    var errorCatched = false
    do {
      _ = try ssh.ConfigDecoder().decode(from: content)
    } catch let ssh.ConfigDecoderError.unableToDecode(path, value, type) {
      assert(path == "port")
      assert(value == "abc")
      assert(type == UInt16.self)
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testUnableToLoad () {
    var errorCatched = false
    do {
      _ = try ssh.Config.load(path: "/nonexistent/path")
    } catch let ssh.ConfigError.unableToLoad(path, cause) {
      assert(path == "/nonexistent/path")
      assert(type(of: cause) == NSError.self)
      // Different messages depend on OS and Swift version,
      // but they say the same - 'No such file'.
      assert(cause.localizedDescription.contains("o such file"))
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testUnableToDump () {
    let config = ssh.Config()

    var errorCatched = false
    do {
      try config.dump(to: "/nonexistent/path")
    } catch let ssh.ConfigError.unableToDump(path, cause) {
      assert(path == "/nonexistent/path")
      assert(type(of: cause) == NSError.self)
      // Different messages depend on OS and Swift version,
      // but they say the same - 'file doesn’t exist'.
      assert(cause.localizedDescription.contains(" doesn’t exist."))
      errorCatched = true
    } catch {}
    assert(errorCatched)
  }

  func testConfigFromJsonString () throws {
    let string = """
    {
      "hosts": [
        {
          "alias": "myserv",
          "properties": {
            "port": 2021
          }
        }
      ]
    }
    """

    let config = try! ssh.Config.from(json: string)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
  }

  func testConfigFromJsonData () throws {
    let string = """
    {
      "hosts": [
        {
          "alias": "myserv",
          "properties": {
            "port": 2021
          }
        }
      ]
    }
    """
    let data = string.data(using: .utf8)!

    let config = try! ssh.Config.from(json: data)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
  }

  func testConfigLoad () throws {
    let content = """
    Host myserv
      port 2021
    """
    try content.write(
      toFile: NSString(string: "~/my-ssh-config").expandingTildeInPath,
      atomically: true,
      encoding: String.Encoding.utf8
    )


    let config = try! ssh.Config.load(path: "~/my-ssh-config")

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
  }

  func testConfigParse () throws {
    let content = """
    Host myserv
      port 2021
    """

    let config = try! ssh.Config.parse(content)

    assert(config.hosts.count == 1)
    assert(config.hosts[0].alias == "myserv")
    assert(config.hosts[0].properties.port == 2021)
  }

  func testConfigInit () throws {
    let config = ssh.Config(
      ssh.Host("github.com gitlab.com",
        { $0.user = "xxlabaza" },
        { $0.identityFile = ["~/.ssh/id_ed25519"] }
      ),
      ssh.Host("myserv",
        { $0.port = 56 },
        { $0.user = "admin" }
      ),
      ssh.Host("*",
        { $0.port = 2020 },
        { $0.user = "artem" },
        { $0.addKeysToAgent = .yes },
        { $0.forwardX11Timeout = ssh.TimeFormat(minutes: 1, seconds: 15) }
      )
    )

    assert(config.hosts.count == 3)

    assert(config.hosts[0].alias == "github.com gitlab.com")
    assert(config.hosts[0].properties.user == "xxlabaza")

    assert(config.hosts[1].alias == "myserv")
    assert(config.hosts[1].properties.port == 56)

    assert(config.hosts[2].alias == "*")
    assert(config.hosts[2].properties.addKeysToAgent == .yes)
  }

  func testConfigToJsonData () throws {
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let data = try! config.toJsonData()

    assert(jsonEquals(
      actual: data,
      expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
    ))
  }

  func testConfigToJsonString () throws {
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let json = try! config.toJsonString()

    assert(jsonEquals(
      actual: json,
      expected: #"{"hosts":[{"alias":"myserv","properties":{"port":15}}]}"#
    ))
  }

  func testConfigToString () throws {
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    let string = try! config.toString()

    assert(string == """
    Host myserv
      Port 15
    """)
  }

  func testConfigDump () throws {
    let config = ssh.Config(
      ssh.Host("myserv", { $0.port = 15 })
    )
    try! config.dump(to: "~/my-ssh-config")

    let filePath = NSString(string: "~/my-ssh-config").expandingTildeInPath
    assert(FileManager.default.fileExists(atPath: filePath))
    assert(try! String(contentsOfFile: filePath) == """
    Host myserv
      Port 15
    """)
  }

  func testConfigResolve () throws {
    let config = ssh.Config(
      ssh.Host("github.com gitlab.com",
        { $0.user = "xxlabaza" }
      ),
      ssh.Host("my*",
        { $0.user = "admin" },
        { $0.port = 56 }
      ),
      ssh.Host("*",
        { $0.user = "artem" },
        { $0.port = 2020 }
      )
    )

    let github = config.resolve(for: "github.com")
    assert(github.user == "xxlabaza")
    assert(github.port == 2020)

    let gitlab = config.resolve(for: "gitlab.com")
    assert(gitlab.user == "xxlabaza")
    assert(gitlab.port == 2020)

    let myserv = config.resolve(for: "myserv")
    assert(myserv.user == "admin")
    assert(myserv.port == 56)

    let example = config.resolve(for: "example.com")
    assert(example.user == "artem")
    assert(example.port == 2020)
  }

  func testHostInit () throws {
    let host = ssh.Host("myserv",
      { $0.user = "admin" },
      { $0.port = 2021 }
    )

    assert(host.alias == "myserv")
    assert(host.properties.user == "admin")
  }

  func testHostInit2 () throws {
    var properties = ssh.Properties.create()
    properties.user = "admin"
    properties.port = 2021

    let host = ssh.Host("myserv", properties)

    assert(host.alias == "myserv")
    assert(host.properties.user == "admin")
  }

  func testPropertiesDefaults () throws {
    var properties = ssh.Properties.defaults;
    properties.addKeysToAgent = .yes

    assert(properties.addKeysToAgent == .yes)
    assert(ssh.Properties.defaults.addKeysToAgent == .no)
  }

  private func jsonEquals (actual: String, expected: String) -> Bool {
    let data = actual.data(using: .utf8)!
    return jsonEquals(actual: data, expected: expected)
  }

  private func jsonEquals (actual: Data, expected: String) -> Bool {
    let left = try! ssh.Config.from(json: actual)
    let right = try! ssh.Config.from(json: expected)

    XCTAssertEqual(left, right, "JSON string:\n\(actual)\ndoesn't equal to:\n\(expected)")
    return true
  }
}
