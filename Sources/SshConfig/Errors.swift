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

public extension ssh {

  /// An error that can occur on `Parsing` proccess.
  enum ConfigParserError: Error, Equatable {

    /**
    This error could be thrown by `ssh.ConfigParser`s if there was an empty
    string for an expected key token (`Host` or property name).

    ```
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
    ```
    */
    case emptyKeyToken

    /**
    This error could be thrown by `ssh.ConfigParser`s if there was an empty
    string for an expected value token (host's alias or property value).

    ```
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
    ```
    */
    case emptyValueToken

    /**
    Found an invalid **delimiter** character **after** a token.

    ```
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
    ```
    */
    case illegalTokensDelimiter(after: String, delimiter: Character)

    /**
    A **token** is in an unexpected place.

    ```
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
    ```
    */
    case unexpectedToken(_ token: String)

    /**
    There is no alias for parsing `Host` config's section.

    ```
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
    ```
    */
    case noAliasForHost

    /**
    A `Host` config section doesn't have any property inside.

    ```
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
    ```
    */
    case noPropertiesForHost

    /// Fired when a generic parsing internal error occurred.
    case internalError(_ message: String)
  }

  /// An error that can occur on `Decoding` proccess.
  enum ConfigDecoderError: Error, Equatable {

    /**
    An attempt was made to decode a **value** by **path** as type.

    ```
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
    ```
    */
    case unableToDecode(path: String, value: String, as: Any.Type)

    /// Decoding value is not present.
    case noValueToDecode(forKey: String? = nil)

    /// Fired when a generic decoding internal error occurred.
    case internalError(_ message: String)
  }

  /// An error that can occur on `Encoding` proccess.
  enum ConfigEncoderError: Error, Equatable {

    /// Fired when a generic encoding internal error occurred.
    case internalError(_ message: String, cause: Error)
  }

  /// Common errors for any actions with SSH config.
  enum ConfigError: Error, Equatable {

    /**
    Can't load a config by **path** because of **cause**.

    ```
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
    ```
    */
    case unableToLoad(path: String, cause: Error)

    /**
    Can't dump a config by **path** because of **cause**.

    ```
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
    ```
    */
    case unableToDump(path: String, cause: Error)
  }
}
