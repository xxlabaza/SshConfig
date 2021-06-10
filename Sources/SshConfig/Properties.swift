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

  /**
  All supported SSH properties are listed here.

  I'm not going to add and support a description of all properties
  and their types, but you can find it in any SSH manual.
  */
  struct Properties: Equatable, Codable {

    /**
    The instance of the properties with their default values.

    A client can use it to create its new instance and
    even override some values without any effect for the defaults.

    ```
    var properties = ssh.Properties.defaults;
    properties.addKeysToAgent = .yes

    assert(properties.addKeysToAgent == .yes)
    assert(ssh.Properties.defaults.addKeysToAgent == .no)
    ```
    */
    public static let defaults = Properties(
      addKeysToAgent: .no,
      addressFamily: .any,
      batchMode: .no,
      bindAddress: nil,
      bindInterface: nil,
      canonicalDomains: nil,
      canonicalizeFallbackLocal: .yes,
      canonicalizeHostname: .no,
      canonicalizeMaxDots: 1,
      canonicalizePermittedCNAMEs: nil,
      caSignatureAlgorithms: [
        "ssh-ed25519",
        "ecdsa-sha2-nistp256",
        "ecdsa-sha2-nistp384",
        "ecdsa-sha2-nistp521",
        "sk-ssh-ed25519@openssh.com",
        "sk-ecdsa-sha2-nistp256@openssh.com",
        "rsa-sha2-512",
        "rsa-sha2-256"
      ],
      certificateFile: nil,
      challengeResponseAuthentication: .yes,
      checkHostIP: .no,
      ciphers: [
        "chacha20-poly1305@openssh.com",
        "aes128-ctr",
        "aes192-ctr",
        "aes256-ctr",
        "aes128-gcm@openssh.com",
        "aes256-gcm@openssh.com"
      ],
      clearAllForwardings: .no,
      compression: .no,
      connectionAttempts: 1,
      connectTimeout: nil,
      controlMaster: .no,
      controlPath: nil,
      controlPersist: .no,
      dynamicForward: nil,
      enableSSHKeysign: .no,
      escapeChar: "~",
      exitOnForwardFailure: .no,
      fingerprintHash: .sha256,
      forwardAgent: .no,
      forwardX11: .no,
      forwardX11Timeout: TimeFormat(minutes: 20),
      forwardX11Trusted: .no,
      gatewayPorts: .no,
      globalKnownHostsFile: ["~/.ssh/known_hosts"],
      gssApiAuthentication: .no,
      gssApiDelegateCredentials: .no,
      hashKnownHosts: .no,
      hostbasedAcceptedAlgorithms: [
        "ssh-ed25519-cert-v01@openssh.com",
        "ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "ecdsa-sha2-nistp384-cert-v01@openssh.com",
        "ecdsa-sha2-nistp521-cert-v01@openssh.com",
        "sk-ssh-ed25519-cert-v01@openssh.com",
        "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "rsa-sha2-512-cert-v01@openssh.com",
        "rsa-sha2-256-cert-v01@openssh.com",
        "ssh-rsa-cert-v01@openssh.com",
        "ssh-ed25519",
        "ecdsa-sha2-nistp256",
        "ecdsa-sha2-nistp384",
        "ecdsa-sha2-nistp521",
        "sk-ssh-ed25519@openssh.com",
        "sk-ecdsa-sha2-nistp256@openssh.com",
        "rsa-sha2-512",
        "rsa-sha2-256",
        "ssh-rsa"
      ],
      hostbasedAuthentication: .no,
      hostKeyAlgorithms: [
        "ssh-ed25519-cert-v01@openssh.com",
        "ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "ecdsa-sha2-nistp384-cert-v01@openssh.com",
        "ecdsa-sha2-nistp521-cert-v01@openssh.com",
        "sk-ssh-ed25519-cert-v01@openssh.com",
        "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "rsa-sha2-512-cert-v01@openssh.com",
        "rsa-sha2-256-cert-v01@openssh.com",
        "ssh-rsa-cert-v01@openssh.com",
        "ssh-ed25519",
        "ecdsa-sha2-nistp256",
        "ecdsa-sha2-nistp384",
        "ecdsa-sha2-nistp521",
        "sk-ecdsa-sha2-nistp256@openssh.com",
        "sk-ssh-ed25519@openssh.com",
        "rsa-sha2-512",
        "rsa-sha2-256",
        "ssh-rsa"
      ],
      hostKeyAlias: nil,
      hostname: nil, // <----!!!! ????
      identitiesOnly: .no,
      identityAgent: nil,
      identityFile: [
        "~/.ssh/id_dsa",
        "~/.ssh/id_ecdsa",
        "~/.ssh/id_ecdsa_sk",
        "~/.ssh/id_ed25519",
        "~/.ssh/id_ed25519_sk",
        "~/.ssh/id_rsa"
      ],
      ignoreUnknown: nil,
      include: nil,
      ipqos: IPQoS(interactive: .af21, nonInteractive: .cs1),
      kbdInteractiveAuthentication: .no,
      kbdInteractiveDevices: nil,
      kexAlgorithms: [
        "curve25519-sha256",
        "curve25519-sha256@libssh.org",
        "ecdh-sha2-nistp256",
        "ecdh-sha2-nistp384",
        "ecdh-sha2-nistp521",
        "diffie-hellman-group-exchange-sha256",
        "diffie-hellman-group16-sha512",
        "diffie-hellman-group18-sha512",
        "diffie-hellman-group14-sha256"
      ],
      knownHostsCommand: nil,
      localCommand: nil,
      localForward: nil,
      logLevel: .INFO,
      logVerbose: nil,
      macs: [
        "umac-64-etm@openssh.com",
        "umac-128-etm@openssh.com",
        "hmac-sha2-256-etm@openssh.com",
        "hmac-sha2-512-etm@openssh.com",
        "hmac-sha1-etm@openssh.com",
        "umac-64@openssh.com",
        "umac-128@openssh.com",
        "hmac-sha2-256",
        "hmac-sha2-512",
        "hmac-sha1"
      ],
      noHostAuthenticationForLocalhost: .no,
      numberOfPasswordPrompts: 3,
      passwordAuthentication: .yes,
      permitLocalCommand: .no,
      permitRemoteOpen: nil,
      pkcs11Provider: nil,
      port: 22,
      preferredAuthentications: [
        .gssapiWithMic,
        .hostbased,
        .publickey,
        .keyboardInteractive,
        .password
      ],
      proxyCommand: nil,
      proxyJump: nil,
      proxyUseFdpass: .no,
      pubkeyAcceptedAlgorithms: [
        "ssh-ed25519-cert-v01@openssh.com",
        "ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "ecdsa-sha2-nistp384-cert-v01@openssh.com",
        "ecdsa-sha2-nistp521-cert-v01@openssh.com",
        "sk-ssh-ed25519-cert-v01@openssh.com",
        "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com",
        "rsa-sha2-512-cert-v01@openssh.com",
        "rsa-sha2-256-cert-v01@openssh.com",
        "ssh-rsa-cert-v01@openssh.com",
        "ssh-ed25519",
        "ecdsa-sha2-nistp256",
        "ecdsa-sha2-nistp384",
        "ecdsa-sha2-nistp521",
        "sk-ssh-ed25519@openssh.com",
        "sk-ecdsa-sha2-nistp256@openssh.com",
        "rsa-sha2-512",
        "rsa-sha2-256",
        "ssh-rsa"
      ],
      pubkeyAuthentication: .yes,
      rekeyLimit: RekeyLimit(throughput: .defaultValue, timeout: .none),
      remoteCommand: nil,
      remoteForward: nil,
      requestTTY: nil,
      revokedHostKeys: nil,
      securityKeyProvider: nil,
      sendEnv: [],
      serverAliveCountMax: 3,
      serverAliveInterval: 0,
      setEnv: [:],
      streamLocalBindMask: 0o177,
      streamLocalBindUnlink: .no,
      strictHostKeyChecking: .ask,
      syslogFacility: .USER,
      tcpKeepAlive: .yes,
      tunnel: .no,
      tunnelDevice: TunnelDevice(local: .any, remote: .any),
      updateHostKeys: .yes,
      user: nil,
      userKnownHostsFile: [
        "~/.ssh/known_hosts",
        "~/.ssh/known_hosts2"
      ],
      verifyHostKeyDNS: .no,
      visualHostKey: .no,
      xAuthLocation: nil
    )

    /**
    Because of some Swift language limitations, I can't make the synthesized initializers public
    without re-writing them, so the static method is a workaround for this.

    - returns: A new `ssh.Properties` instance.
    */
    public static func create () -> Properties {
      return Properties()
    }

    static func delimiter (for propertyName: String) -> String? {
      switch propertyName.lowercased() {
      case "casignaturealgorithms",
          "ciphers",
          "hostbasedacceptedalgorithms",
          "hostkeyalgorithms",
          "ignoreunknown",
          "kbdinteractivedevices",
          "kexalgorithms",
          "logverbose",
          "macs",
          "preferredauthentications",
          "proxyjump":
        return ","
      case "canonicaldomains",
          "canonicalizepermittedcnames",
          "globalknownhostsfile",
          "revokedhostkeys",
          "userknownhostsfile":
        return " "
      default:
        return nil
      }
    }

    public var addKeysToAgent: AddKeysToAgent?
    public var addressFamily: AddressFamily?
    public var batchMode: YesNo?
    public var bindAddress: String?
    public var bindInterface: String?
    public var canonicalDomains: [String]?
    public var canonicalizeFallbackLocal: YesNo?
    public var canonicalizeHostname: CanonicalizeHostname?
    public var canonicalizeMaxDots: UInt8?
    public var canonicalizePermittedCNAMEs: [String]?
    public var caSignatureAlgorithms: [String]?
    public var certificateFile: [String]?
    public var challengeResponseAuthentication: YesNo?
    public var checkHostIP: YesNo?
    public var ciphers: [String]?
    public var clearAllForwardings: YesNo?
    public var compression: YesNo?
    public var connectionAttempts: UInt?
    public var connectTimeout: UInt?
    public var controlMaster: ControlMaster?
    @NoneAsNil public var controlPath: String?
    public var controlPersist: ControlPersist?
    public var dynamicForward: String?
    public var enableSSHKeysign: YesNo?
    @NoneAsNil public var escapeChar: String?
    public var exitOnForwardFailure: YesNo?
    public var fingerprintHash: FingerprintHash?
    public var forwardAgent: ForwardAgent?
    public var forwardX11: YesNo?
    public var forwardX11Timeout: TimeFormat?
    public var forwardX11Trusted: YesNo?
    public var gatewayPorts: YesNo?
    public var globalKnownHostsFile: [String]?
    public var gssApiAuthentication: YesNo?
    public var gssApiDelegateCredentials: YesNo?
    public var hashKnownHosts: YesNo?
    public var hostbasedAcceptedAlgorithms: [String]?
    public var hostbasedAuthentication: YesNo?
    public var hostKeyAlgorithms: [String]?
    public var hostKeyAlias: String?
    public var hostname: String?
    public var identitiesOnly: YesNo?
    @NoneAsNil public var identityAgent: IdentityAgent?
    public var identityFile: [String]?
    public var ignoreUnknown: [String]?
    public var include: [String]?
    public var ipqos: IPQoS?
    public var kbdInteractiveAuthentication: YesNo?
    public var kbdInteractiveDevices: [String]?
    public var kexAlgorithms: [String]?
    public var knownHostsCommand: String?
    public var localCommand: String?
    public var localForward: [Forwarding]?
    public var logLevel: LogLevel?
    public var logVerbose: [String]?
    public var macs: [String]?
    public var noHostAuthenticationForLocalhost: YesNo?
    public var numberOfPasswordPrompts: UInt8?
    public var passwordAuthentication: YesNo?
    public var permitLocalCommand: YesNo?
    public var permitRemoteOpen: [String]?
    @NoneAsNil public var pkcs11Provider: String?
    public var port: UInt16?
    public var preferredAuthentications: [PreferredAuthentications]?
    public var proxyCommand: String?
    public var proxyJump: [String]?
    public var proxyUseFdpass: YesNo?
    public var pubkeyAcceptedAlgorithms: [String]?
    public var pubkeyAuthentication: YesNo?
    public var rekeyLimit: RekeyLimit?
    public var remoteCommand: String?
    public var remoteForward: [Forwarding]?
    public var requestTTY: RequestTTY?
    public var revokedHostKeys: String?
    public var securityKeyProvider: String?
    public var sendEnv: [String]?
    public var serverAliveCountMax: UInt16?
    public var serverAliveInterval: UInt16?
    public var setEnv: [String: String]?
    public var streamLocalBindMask: Int? /* octal */
    public var streamLocalBindUnlink: YesNo?
    public var strictHostKeyChecking: StrictHostKeyChecking?
    public var syslogFacility: SyslogFacility?
    public var tcpKeepAlive: YesNo?
    public var tunnel: Tunnel?
    public var tunnelDevice: TunnelDevice?
    public var updateHostKeys: YesAskNo?
    public var user: String?
    public var userKnownHostsFile: [String]?
    public var verifyHostKeyDNS: YesAskNo?
    public var visualHostKey: YesNo?
    public var xAuthLocation: String?
    public var unparsed: [String: [String]]?
  }

  enum AddKeysToAgent: SshPropertyType {

    case yes
    case no
    case confirm
    case ask
    case interval(TimeFormat)

    public var description: String {
      switch self {
      case .yes:
        return "yes"
      case .no:
        return "no"
      case .confirm:
        return "confirm"
      case .ask:
        return "ask"
      case let .interval(timeFormat):
        return "\(timeFormat)"
      }
    }

    public init? (rawValue: String) {
      switch rawValue {
      case "yes":
        self = .yes
      case "no":
        self = .no
      case "confirm":
        self = .confirm
      case "ask":
        self = .ask
      default:
        guard let timeFormat = TimeFormat(rawValue: rawValue) else {
          return nil
        }
        self = .interval(timeFormat)
      }
    }
  }

  enum AddressFamily: String, Equatable, Codable {

    case any
    case inet
    case inet6
  }

  enum YesNo: String, Equatable, Codable {

    case yes
    case no
  }

  enum YesAskNo: String, Equatable, Codable {

    case yes
    case ask
    case no
  }

  enum CanonicalizeHostname: String, Equatable, Codable {

    case yes
    case no
    case always
  }

  enum ControlMaster: String, Equatable, Codable {

    case yes
    case no
    case ask
    case auto
    case autoask
  }

  enum ControlPersist: SshPropertyType {

    case yes
    case no
    case interval(TimeFormat)

    public var description: String {
      switch self {
      case .yes:
        return "yes"
      case .no:
        return "no"
      case let .interval(timeFormat):
        return "\(timeFormat)"
      }
    }

    public init? (rawValue: String) {
      switch rawValue {
      case "yes":
        self = .yes
      case "no":
        self = .no
      default:
        guard let timeFormat = TimeFormat(rawValue: rawValue) else {
          return nil
        }
        self = .interval(timeFormat)
      }
    }
  }

  enum FingerprintHash: String, Equatable, Codable {

    case md5
    case sha256
  }

  enum ForwardAgent: SshPropertyType {

    case yes
    case no
    case socket(String)
    case environmentVariable(String)

    public var description: String {
      switch self {
      case .yes:
        return "yes"
      case .no:
        return "no"
      case let .socket(value):
        return value
      case let .environmentVariable(value):
        if let firstCharacter = value.first, firstCharacter == "$" {
          return value
        } else {
          return "$\(value)"
        }
      }
    }

    public init? (rawValue: String) {
      if rawValue == "yes" {
        self = .yes
        return
      } else if rawValue == "no" {
        self = .no
        return
      }

      if let firstCharacter = rawValue.first, firstCharacter == "$" {
        self = .environmentVariable(String(rawValue.dropFirst()))
      } else {
        self = .socket(rawValue)
      }
    }
  }

  struct TimeFormat: SshPropertyType {

    public var weeks: UInt?
    public var days: UInt?
    public var hours: UInt?
    public var minutes: UInt?
    public var seconds: UInt?

    public var description: String {
      var result = ""
      if let weeks = weeks {
        result.append("\(weeks)w")
      }
      if let days = days {
        result.append("\(days)d")
      }
      if let hours = hours {
        result.append("\(hours)h")
      }
      if let minutes = minutes {
        result.append("\(minutes)m")
      }
      if let seconds = seconds {
        result.append("\(seconds)s")
      }
      return result
    }

    public init (weeks: UInt? = nil, days: UInt? = nil, hours: UInt? = nil, minutes: UInt? = nil, seconds: UInt? = nil) {
      self.weeks = weeks
      self.days = days
      self.hours = hours
      self.minutes = minutes
      self.seconds = seconds
    }

    public init? (rawValue: String) {
      if let secondsValue = UInt(rawValue) {
        self.seconds = secondsValue
        return
      }

      var digits: String = ""
      for char in rawValue {
        if char.isNumber {
          digits.append(char)
          continue
        } else if char.isLetter == false {
          return nil
        }

        guard let number = UInt(digits) else {
          return nil
        }
        switch char.lowercased() {
        case "w":
          self.weeks = number
        case "d":
          self.days = number
        case "h":
          self.hours = number
        case "m":
          self.minutes = number
        case "s":
          self.seconds = number
        default:
          return nil
        }
        digits = ""
      }
    }
  }

  enum IdentityAgent: SshPropertyType {

    case socket(String)
    case environmentVariable(String)

    public var description: String {
      switch self {
      case let .socket(value):
        return value
      case let .environmentVariable(value):
        if let firstCharacter = value.first, firstCharacter == "$" {
          return value
        } else {
          return "$\(value)"
        }
      }
    }

    public init? (rawValue: String) {
      if let firstCharacter = rawValue.first, firstCharacter == "$" {
        self = .environmentVariable(String(rawValue.dropFirst()))
      } else {
        self = .socket(rawValue)
      }
    }
  }

  struct IPQoS: SshPropertyType {

    public var interactive: Quality? = .af21
    public var nonInteractive: Quality? = .cs1

    public var description: String {
      return "\(interactive?.description ?? "none") \(nonInteractive?.description ?? "none")"
    }

    public init (interactive: Quality? = .af21, nonInteractive: Quality? = .cs1) {
      self.interactive = interactive
      self.nonInteractive = nonInteractive
    }

    public init? (rawValue: String) {
      let tokens = rawValue.toTokens()
      switch tokens.count {
      case 1:
        interactive = Quality(rawValue: tokens[0])
      case 2:
        interactive = Quality(rawValue: tokens[0])
        nonInteractive = Quality(rawValue: tokens[1])
      default:
        return nil
      }
    }

    public enum Quality: SshPropertyType {

      case af11
      case af12
      case af13
      case af21
      case af22
      case af23
      case af31
      case af32
      case af33
      case af41
      case af42
      case af43
      case cs0
      case cs1
      case cs2
      case cs3
      case cs4
      case cs5
      case cs6
      case cs7
      case ef
      case le
      case lowdelay
      case throughput
      case reliability
      case numeric(Int)

      public var description: String {
        switch self {
        case .af11:
          return "af11"
        case .af12:
          return "af12"
        case .af13:
          return "af13"
        case .af21:
          return "af21"
        case .af22:
          return "af22"
        case .af23:
          return "af23"
        case .af31:
          return "af31"
        case .af32:
          return "af32"
        case .af33:
          return "af33"
        case .af41:
          return "af41"
        case .af42:
          return "af42"
        case .af43:
          return "af43"
        case .cs0:
          return "cs0"
        case .cs1:
          return "cs1"
        case .cs2:
          return "cs2"
        case .cs3:
          return "cs3"
        case .cs4:
          return "cs4"
        case .cs5:
          return "cs5"
        case .cs6:
          return "cs6"
        case .cs7:
          return "cs7"
        case .ef:
          return "ef"
        case .le:
          return "le"
        case .lowdelay:
          return "lowdelay"
        case .throughput:
          return "throughput"
        case .reliability:
          return "reliability"
        case let .numeric(value):
          return "\(value)"
        }
      }

      public init? (rawValue: String) {
        if rawValue.isHex {
          self = .numeric(rawValue.hexToDecimal)
          return
        } else if let number = Int(rawValue) {
          self = .numeric(number)
          return
        }

        switch rawValue {
        case "af11":
          self = .af11
        case "af12":
          self = .af12
        case "af13":
          self = .af13
        case "af21":
          self = .af21
        case "af22":
          self = .af22
        case "af23":
          self = .af23
        case "af31":
          self = .af31
        case "af32":
          self = .af32
        case "af33":
          self = .af33
        case "af41":
          self = .af41
        case "af42":
          self = .af42
        case "af43":
          self = .af43
        case "cs0":
          self = .cs0
        case "cs1":
          self = .cs1
        case "cs2":
          self = .cs2
        case "cs3":
          self = .cs3
        case "cs4":
          self = .cs4
        case "cs5":
          self = .cs5
        case "cs6":
          self = .cs6
        case "cs7":
          self = .cs7
        case "ef":
          self = .ef
        case "le":
          self = .le
        case "lowdelay":
          self = .lowdelay
        case "throughput":
          self = .throughput
        case "reliability":
          self = .reliability
        default:
          return nil
        }
      }
    }
  }

  struct Forwarding: SshPropertyType {

    public var bind: String
    public var host: String?

    public var description: String {
      if let host = host {
        return "\(bind) \(host)"
      } else {
        return bind
      }
    }

    public init (bind: String, host: String? = nil) {
      self.bind = bind
      self.host = host
    }

    public init? (rawValue: String) {
      let tokens = rawValue.toTokens()
      switch tokens.count {
      case 1:
        bind = tokens[0]
      case 2:
        bind = tokens[0]
        host = tokens[1]
      default:
        return nil
      }
    }
  }

  enum LogLevel: String, Equatable, Codable {

    case QUIET
    case FATAL
    case ERROR
    case INFO
    case VERBOSE
    case DEBUG
    case DEBUG1
    case DEBUG2
    case DEBUG3
  }

  enum PreferredAuthentications: String, Equatable, Codable {

    case gssapiWithMic = "gssapi-with-mic"
    case hostbased
    case publickey
    case keyboardInteractive = "keyboard-interactive"
    case password
  }

  struct RekeyLimit: SshPropertyType {

    public var throughput: Throughput = .defaultValue
    public var timeout: TimeFormat? = nil

    public var description: String {
      return "\(throughput) \(timeout?.description ?? "none")"
    }

    public init (throughput: Throughput = .defaultValue, timeout: TimeFormat? = nil) {
      self.throughput = throughput
      self.timeout = timeout
    }

    public init? (rawValue: String) {
      let tokens = rawValue.toTokens()
      switch tokens.count {
      case 1:
        throughput = Throughput(rawValue: tokens[0])!
      case 2:
        throughput = Throughput(rawValue: tokens[0])!
        timeout = tokens[1] == "none" ? nil : TimeFormat(rawValue: tokens[1])
      default:
        return nil
      }
    }

    public enum Throughput: SshPropertyType {

      case kilobytes(UInt)
      case megabytes(UInt)
      case gigabytes(UInt)
      case defaultValue

      public var description: String {
        switch self {
        case let .kilobytes(value):
          return "\(value)K"
        case let .megabytes(value):
          return "\(value)M"
        case let .gigabytes(value):
          return "\(value)G"
        case .defaultValue:
          return "default"
        }
      }

      public init? (rawValue: String) {
        if rawValue == "default" {
          self = .defaultValue
          return
        }
        guard let lastChar = rawValue.last else {
          return nil
        }

        let index = rawValue.index(rawValue.endIndex, offsetBy: -1)
        let digits = rawValue[..<index]
        guard let number = UInt(digits) else {
          return nil
        }

        switch lastChar {
        case "K", "k":
          self = .kilobytes(number)
        case "M", "m":
          self = .megabytes(number)
        case "G", "g":
          self = .gigabytes(number)
        default:
          return nil
        }
      }
    }
  }

  enum RequestTTY: String, Equatable, Codable {

    case no
    case yes
    case force
    case auto
  }

  enum StrictHostKeyChecking: String, Equatable, Codable {

    case yes
    case acceptNew = "accept-new"
    case off
    case no
    case ask
  }

  enum SyslogFacility: String, Equatable, Codable {

    case DAEMON
    case USER
    case AUTH
    case LOCAL0
    case LOCAL1
    case LOCAL2
    case LOCAL3
    case LOCAL4
    case LOCAL5
    case LOCAL6
    case LOCAL7
  }

  enum Tunnel: String, Equatable, Codable {

    case yes
    case pointToPoint = "point-to-point"
    case ethernet
    case no
  }

  struct TunnelDevice: SshPropertyType {

    public var local: Device = .any
    public var remote: Device = .any

    public var description: String {
      return "\(local):\(remote)"
    }

    public init (local: Device = .any, remote: Device = .any) {
      self.local = local
      self.remote = remote
    }

    public init? (rawValue: String) {
      let tokens = rawValue.toTokens(delimiter: ":")
      switch tokens.count {
      case 1:
        local = Device(rawValue: tokens[0])!
      case 2:
        local = Device(rawValue: tokens[0])!
        remote = Device(rawValue: tokens[1])!
      default:
        return nil
      }
    }

    public enum Device: SshPropertyType {

      case id(Int)
      case any

      public var description: String {
        switch self {
        case let .id(value):
          return "\(value)"
        case .any:
          return "any"
        }
      }

      public init? (rawValue: String) {
        if rawValue == "any" {
          self = .any
          return
        }
        guard let number = Int(rawValue) else {
          return nil
        }
        self = .id(number)
      }
    }
  }
}

protocol SshPropertyType: Equatable, Codable, CustomStringConvertible {

  init? (rawValue: String)
}

extension SshPropertyType {

  public init (from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = Self(rawValue: string)!
  }

  public func encode (to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}
