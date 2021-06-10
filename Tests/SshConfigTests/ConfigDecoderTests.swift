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

final class ConfigDecoderTests: XCTestCase {

  func testSimpleConfig () throws {
    let content = """
    Host myserv
      port 2021
      user ZadirA
    """

    try assertConfigs(content, ssh.Config(
      ssh.Host("myserv",
        { $0.port = 2021 },
        { $0.user = "ZadirA" }
      )
    ))
  }

  func testComplexConfig () throws {
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

    try assertConfigs(content, ssh.Config(
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
        { $0.addKeysToAgent = .no }
      )
    ))
  }

  func testMultipleOccursOfSingleValue () throws {
    try check(
      field: \.addKeysToAgent,
      expected: .ask,
      config: """
        ADDKEYSTOAGENT=confirm
        ADDKEYSTOAGENT=ask
      """
    )
  }

  func testPasingOf_addKeysToAgent () throws {
    try check(
      field: \.addKeysToAgent,
      expected: .confirm,
      config: "ADDKEYSTOAGENT=confirm"
    )
  }

  func testPasingOf_addressFamily () throws {
    try check(
      field: \.addressFamily,
      expected: .inet6,
      config: "addressFamily inet6"
    )
  }

  func testPasingOf_batchMode () throws {
    try check(
      field: \.batchMode,
      expected: .yes,
      config: "batchMode yes"
    )
  }

  func testPasingOf_bindAddress () throws {
    try check(
      field: \.bindAddress,
      expected: "127.0.0.1",
      config: "bindaddress 127.0.0.1"
    )
  }

  func testPasingOf_bindInterface () throws {
    try check(
      field: \.bindInterface,
      expected: "127.0.0.1",
      config: "bindInterface 127.0.0.1"
    )
  }

  func testPasingOf_canonicalDomains () throws {
    try check(
      field: \.canonicalDomains,
      expected: ["example.com", "int.example.com"],
      config: "canonicalDomains example.com int.example.com"
    )
  }

  func testPasingOf_canonicalizeFallbackLocal () throws {
    try check(
      field: \.canonicalizeFallbackLocal,
      expected: .no,
      config: "canonicalizeFallbackLocal no"
    )
  }

  func testPasingOf_canonicalizeHostname () throws {
    try check(
      field: \.canonicalizeHostname,
      expected: .always,
      config: "canonicalizeHostname=always"
    )
  }

  func testPasingOf_canonicalizeMaxDots () throws {
    try check(
      field: \.canonicalizeMaxDots,
      expected: 1,
      config: "canonicalizeMaxDots 1"
    )
  }

  func testPasingOf_canonicalizePermittedCNAMEs () throws {
    try check(
      field: \.canonicalizePermittedCNAMEs,
      expected: ["mail.*.example.com:anycast-mail.int.example.com", "dns*.example.com:dns*.dmz.example.com"],
      config: "canonicalizePermittedCNAMEs mail.*.example.com:anycast-mail.int.example.com dns*.example.com:dns*.dmz.example.com"
    )
  }

  func testPasingOf_caSignatureAlgorithms () throws {
    try check(
      field: \.caSignatureAlgorithms,
      expected: ["ecdsa-sha2-nistp256", "ecdsa-sha2-nistp384", "ecdsa-sha2-nistp521"],
      config: "casignaturealgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521"
    )
  }

  func testPasingOf_certificateFile () throws {
    try check(
      field: \.certificateFile,
      expected: ["~/.ssh/id_ed25519-cert-ca1.pub", "~/.ssh/id_ed25519-cert-ca2.pub"],
      config: """
        CertificateFile ~/.ssh/id_ed25519-cert-ca1.pub
        CertificateFile ~/.ssh/id_ed25519-cert-ca2.pub
      """
    )
  }

  func testPasingOf_challengeResponseAuthentication () throws {
    try check(
      field: \.challengeResponseAuthentication,
      expected: .no,
      config: "challengeResponseAuthentication no"
    )
  }

  func testPasingOf_checkHostIP () throws {
    try check(
      field: \.checkHostIP,
      expected: .yes,
      config: "checkHostIP yes"
    )
  }

  func testPasingOf_ciphers () throws {
    try check(
      field: \.ciphers,
      expected: ["aes256-ctr", "aes256-cbc"],
      config: "ciphers aes256-ctr,aes256-cbc"
    )
  }

  func testPasingOf_clearAllForwardings () throws {
    try check(
      field: \.clearAllForwardings,
      expected: .no,
      config: "clearAllForwardings no"
    )
  }

  func testPasingOf_compression () throws {
    try check(
      field: \.compression,
      expected: .yes,
      config: "CoMpRESsION yes"
    )
  }

  func testPasingOf_connectionAttempts () throws {
    try check(
      field: \.connectionAttempts,
      expected: 3,
      config: "connectionAttempts 3"
    )
  }

  func testPasingOf_connectTimeout () throws {
    try check(
      field: \.connectTimeout,
      expected: 17,
      config: "connectTimeout 17"
    )
  }

  func testPasingOf_controlMaster () throws {
    try check(
      field: \.controlMaster,
      expected: .autoask,
      config: "controlMaster autoask"
    )
  }

  func testPasingOf_controlPath () throws {
    try check(
      field: \.controlPath,
      expected: nil,
      config: "controlPath none"
    )
    try check(
      field: \.controlPath,
      expected: "~/.ssh/cm_socket/%r@%h:%p",
      config: "controlPath ~/.ssh/cm_socket/%r@%h:%p"
    )
    try check(
      field: \.controlPath,
      expected: "none",
      config: "controlPath none"
    )
  }

  func testPasingOf_controlPersist () throws {
    try check(
      field: \.controlPersist,
      expected: .yes,
      config: "controlPersist yes"
    )
    try check(
      field: \.controlPersist,
      expected: .interval(ssh.TimeFormat(weeks: 1, days: 3)),
      config: "controlPersist 1w3d"
    )
    try check(
      field: \.controlPersist,
      expected: .interval(ssh.TimeFormat(seconds: 10)),
      config: "controlPersist 10"
    )
  }

  func testPasingOf_dynamicForward () throws {
    try check(
      field: \.dynamicForward,
      expected: "localhost:5555",
      config: "dynamicForward localhost:5555"
    )
  }

  func testPasingOf_enableSSHKeysign () throws {
    try check(
      field: \.enableSSHKeysign,
      expected: .no,
      config: "enableSSHKeysign no"
    )
  }

  func testPasingOf_escapeChar () throws {
    try check(
      field: \.escapeChar,
      expected: nil,
      config: "escapeChar none"
    )
    try check(
      field: \.escapeChar,
      expected: "^",
      config: "escapeChar ^"
    )
  }

  func testPasingOf_exitOnForwardFailure () throws {
    try check(
      field: \.exitOnForwardFailure,
      expected: .yes,
      config: "exitOnForwardFailure yes"
    )
  }

  func testPasingOf_fingerprintHash () throws {
    try check(
      field: \.fingerprintHash,
      expected: .sha256,
      config: "fingerprintHash sha256"
    )
  }

  func testPasingOf_forwardAgent () throws {
    try check(
      field: \.forwardAgent,
      expected: .yes,
      config: "forwardAgent yes"
    )
    try check(
      field: \.forwardAgent,
      expected: .environmentVariable("POPA"),
      config: "forwardAgent $POPA"
    )
  }

  func testPasingOf_forwardX11 () throws {
    try check(
      field: \.forwardX11,
      expected: .yes,
      config: "forwardX11 yes"
    )
  }

  func testPasingOf_forwardX11Timeout () throws {
    try check(
      field: \.forwardX11Timeout,
      expected: ssh.TimeFormat(seconds: 15),
      config: "forwardX11Timeout 15"
    )
  }

  func testPasingOf_forwardX11Trusted () throws {
    try check(
      field: \.forwardX11Trusted,
      expected: .no,
      config: "forwardX11Trusted no"
    )
  }

  func testPasingOf_gatewayPorts () throws {
    try check(
      field: \.gatewayPorts,
      expected: .yes,
      config: "gatewayPorts yes"
    )
  }

  func testPasingOf_globalKnownHostsFile () throws {
    try check(
      field: \.globalKnownHostsFile,
      expected: ["/etc/ssh/ssh_known_hosts", "/etc/ssh/ssh_known_hosts2"],
      config: "globalKnownHostsFile /etc/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts2"
    )
  }

  func testPasingOf_gssApiAuthentication () throws {
    try check(
      field: \.gssApiAuthentication,
      expected: .no,
      config: "gssApiAuthentication no"
    )
  }

  func testPasingOf_gssApiDelegateCredentials () throws {
    try check(
      field: \.gssApiDelegateCredentials,
      expected: .yes,
      config: "gssApiDelegateCredentials yes"
    )
  }

  func testPasingOf_hashKnownHosts () throws {
    try check(
      field: \.hashKnownHosts,
      expected: .no,
      config: "hashKnownHosts no"
    )
  }

  func testPasingOf_hostbasedAcceptedAlgorithms () throws {
    try check(
      field: \.hostbasedAcceptedAlgorithms,
      expected: ["ssh-ed25519-cert-v01@openssh.com", "ecdsa-sha2-nistp256-cert-v01@openssh.com"],
      config: "hostbasedAcceptedAlgorithms ssh-ed25519-cert-v01@openssh.com, ecdsa-sha2-nistp256-cert-v01@openssh.com"
    )
  }

  func testPasingOf_hostbasedAuthentication () throws {
    try check(
      field: \.hostbasedAuthentication,
      expected: .yes,
      config: "hostbasedAuthentication yes"
    )
  }

  func testPasingOf_hostKeyAlgorithms () throws {
    try check(
      field: \.hostKeyAlgorithms,
      expected: ["ssh-ed25519", "nistp521"],
      config: "hostKeyAlgorithms ssh-ed25519, nistp521"
    )
  }

  func testPasingOf_hostKeyAlias () throws {
    try check(
      field: \.hostKeyAlias,
      expected: "myserver.example.com",
      config: "HostKeyAlias myserver.example.com"
    )
  }

  func testPasingOf_hostname () throws {
    try check(
      field: \.hostname,
      expected: "server1.cyberciti.biz",
      config: "HostName server1.cyberciti.biz"
    )
  }

  func testPasingOf_identitiesOnly () throws {
    try check(
      field: \.identitiesOnly,
      expected: .no,
      config: "identitiesOnly no"
    )
  }

  func testPasingOf_identityAgent () throws {
    try check(
      field: \.identityAgent,
      expected: nil,
      config: "identityAgent none"
    )
    try check(
      field: \.identityAgent,
      expected: .socket("~/agent-socket-id1"),
      config: "identityAgent ~/agent-socket-id1"
    )
    try check(
      field: \.identityAgent,
      expected: .environmentVariable("SSH_AUTH_SOCK_ID1"),
      config: "identityAgent $SSH_AUTH_SOCK_ID1"
    )
  }

  func testPasingOf_identityFile () throws {
    try check(
      field: \.identityFile,
      expected: ["~/.ssh/id_rsa", "~/.ssh/id_rsa_old", "~/.ssh/id_ed25519"],
      config: """
        IdentityFile ~/.ssh/id_rsa
        IdentityFile ~/.ssh/id_rsa_old
        IdentityFile ~/.ssh/id_ed25519
      """
    )
  }

  func testPasingOf_ignoreUnknown () throws {
    try check(
      field: \.ignoreUnknown,
      expected: ["HostBasedKeyTypes", "IgnoreIfUnknown"],
      config: "ignoreUnknown HostBasedKeyTypes,IgnoreIfUnknown"
    )
  }

  func testPasingOf_include () throws {
    try check(
      field: \.include,
      expected: ["~/.ssh/1_config", "~/.ssh/2_config"],
      config: """
        include=~/.ssh/1_config
        include=~/.ssh/2_config
      """
    )
  }

  func testPasingOf_ipqos () throws {
    try check(
      field: \.ipqos,
      expected: ssh.IPQoS(interactive: .numeric(255)),
      config: "ipqos 0xff"
    )
    try check(
      field: \.ipqos,
      expected: ssh.IPQoS(interactive: .throughput, nonInteractive: .cs1),
      config: "ipqos=throughput"
    )
    try check(
      field: \.ipqos,
      expected: ssh.IPQoS(interactive: .numeric(13), nonInteractive: nil),
      config: "ipqos 13 none"
    )
  }

  func testPasingOf_kbdInteractiveAuthentication () throws {
    try check(
      field: \.kbdInteractiveAuthentication,
      expected: .yes,
      config: "kbdInteractiveAuthentication=yes"
    )
  }

  func testPasingOf_kbdInteractiveDevices () throws {
    try check(
      field: \.kbdInteractiveDevices,
      expected: ["pam", "skey", "bsdauth"],
      config: "KbdInteractiveDevices = pam,skey,bsdauth"
    )
  }

  func testPasingOf_kexAlgorithms () throws {
    try check(
      field: \.kexAlgorithms,
      expected: ["ecdh-sha2-nistp256", "ecdh-sha2-nistp384"],
      config: "kexAlgorithms=ecdh-sha2-nistp256 , ecdh-sha2-nistp384"
    )
  }

  func testPasingOf_knownHostsCommand () throws {
    try check(
      field: \.knownHostsCommand,
      expected: "command",
      config: "knownHostsCommand command"
    )
  }

  func testPasingOf_localCommand () throws {
    try check(
      field: \.localCommand,
      expected: "cd / && exec bash --login",
      config: "LocalCommand cd / && exec bash --login"
    )
  }

  func testPasingOf_localForward () throws {
    try check(
      field: \.localForward,
      expected: [ssh.Forwarding(bind: "5901", host: "computer.myHost.edu:5901")],
      config: "LocalForward 5901 computer.myHost.edu:5901"
    )
    try check(
      field: \.localForward,
      expected: [
        ssh.Forwarding(bind: "8090", host: "192.168.1.100:8081"),
        ssh.Forwarding(bind: "8091", host: "192.168.1.101:8081")
      ],
      config: """
        LocalForward 8090 192.168.1.100:8081
        LocalForward 8091 192.168.1.101:8081
      """
    )
  }

  func testPasingOf_logLevel () throws {
    try check(
      field: \.logLevel,
      expected: .QUIET,
      config: "Loglevel QUIET"
    )
  }

  func testPasingOf_logVerbose () throws {
    try check(
      field: \.logVerbose,
      expected: ["kex.c:*:1000", "*:kex_exchange_identification():*", "packet.c:*"],
      config: "logverbose kex.c:*:1000,*:kex_exchange_identification():*,packet.c:*"
    )
  }

  func testPasingOf_macs () throws {
    try check(
      field: \.macs,
      expected: ["hmac-sha2-512-etm@openssh.com", "hmac-sha2-256-etm@openssh.com", "umac-128-etm@openssh.com", "hmac-sha2-512"],
      config: "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512"
    )
  }

  func testPasingOf_noHostAuthenticationForLocalhost () throws {
    try check(
      field: \.noHostAuthenticationForLocalhost,
      expected: .no,
      config: "noHostAuthenticationForLocalhost no"
    )
  }

  func testPasingOf_numberOfPasswordPrompts () throws {
    try check(
      field: \.numberOfPasswordPrompts,
      expected: 3,
      config: "NumberOfPasswordPrompts 3"
    )
  }

  func testPasingOf_passwordAuthentication () throws {
    try check(
      field: \.passwordAuthentication,
      expected: .yes,
      config: "passwordAuthentication yes"
    )
  }

  func testPasingOf_permitLocalCommand () throws {
    try check(
      field: \.permitLocalCommand,
      expected: .no,
      config: "permitLocalCommand no"
    )
  }

  func testPasingOf_permitRemoteOpen () throws {
    try check(
      field: \.permitRemoteOpen,
      expected: ["8080"],
      config: "PermitRemoteOpen 8080"
    )
  }

  func testPasingOf_pkcs11Provider () throws {
    try check(
      field: \.pkcs11Provider,
      expected: "/usr/local/opt/opensc/lib/pkcs11/opensc-pkcs11.so",
      config: "PKCS11Provider /usr/local/opt/opensc/lib/pkcs11/opensc-pkcs11.so"
    )
    try check(
      field: \.pkcs11Provider,
      expected: nil,
      config: "PKCS11Provider none"
    )
  }

  func testPasingOf_port () throws {
    try check(
      field: \.port,
      expected: 8080,
      config: "Port 8080"
    )
  }

  func testPasingOf_preferredAuthentications () throws {
    try check(
      field: \.preferredAuthentications,
      expected: [.keyboardInteractive, .password, .publickey, .hostbased, .gssapiWithMic],
      config: "preferredAuthentications keyboard-interactive,password,publickey,hostbased,gssapi-with-mic"
    )
  }

  func testPasingOf_proxyCommand () throws {
    try check(
      field: \.proxyCommand,
      expected: "ssh jumphost.nixcraft.com -W %h:%p",
      config: "ProxyCommand ssh jumphost.nixcraft.com -W %h:%p"
    )
  }

  func testPasingOf_proxyJump () throws {
    try check(
      field: \.proxyJump,
      expected: ["user1@jumphost1.example.org:22", "user2@jumphost2.example.org:2222"],
      config: "ProxyJump user1@jumphost1.example.org:22,user2@jumphost2.example.org:2222"
    )
  }

  func testPasingOf_proxyUseFdpass () throws {
    try check(
      field: \.proxyUseFdpass,
      expected: .no,
      config: "proxyUseFdpass no"
    )
  }

  func testPasingOf_pubkeyAcceptedAlgorithms () throws {
    try check(
      field: \.pubkeyAcceptedAlgorithms,
      expected: ["^ssh-rsa"],
      config: "pubkeyAcceptedAlgorithms ^ssh-rsa"
    )
  }

  func testPasingOf_pubkeyAuthentication () throws {
    try check(
      field: \.pubkeyAuthentication,
      expected: .yes,
      config: "pubkeyAuthentication yes"
    )
  }

  func testPasingOf_rekeyLimit () throws {
    try check(
      field: \.rekeyLimit,
      expected: ssh.RekeyLimit(timeout: ssh.TimeFormat(seconds: 60)),
      config: "RekeyLimit default 60"
    )
    try check(
      field: \.rekeyLimit,
      expected: ssh.RekeyLimit(throughput: .gigabytes(1)),
      config: "RekeyLimit 1G"
    )
    try check(
      field: \.rekeyLimit,
      expected: ssh.RekeyLimit(throughput: .megabytes(3), timeout: ssh.TimeFormat(minutes: 10)),
      config: "RekeyLimit 3M 10m"
    )
  }

  func testPasingOf_remoteCommand () throws {
    try check(
      field: \.remoteCommand,
      expected: "cd / && exec bash --login",
      config: "remotecommand=cd / && exec bash --login"
    )
  }

  func testPasingOf_remoteForward () throws {
    try check(
      field: \.remoteForward,
      expected: [ssh.Forwarding(bind: "55555", host: "localhost:22")],
      config: "RemoteForward 55555 localhost:22"
    )
  }

  func testPasingOf_requestTTY () throws {
    try check(
      field: \.requestTTY,
      expected: .yes,
      config: "RequestTTY yes"
    )
    try check(
      field: \.requestTTY,
      expected: .force,
      config: "RequestTTY force"
    )
  }

  func testPasingOf_revokedHostKeys () throws {
    try check(
      field: \.revokedHostKeys,
      expected: "/etc/ssh/ssh_revoked_host_keys",
      config: "RevokedHostKeys /etc/ssh/ssh_revoked_host_keys"
    )
  }

  func testPasingOf_securityKeyProvider () throws {
    try check(
      field: \.securityKeyProvider,
      expected: "internal",
      config: "securitykeyprovider internal"
    )
  }

  func testPasingOf_sendEnv () throws {
    try check(
      field: \.sendEnv,
      expected: ["FOO_1", "FOO_2"],
      config: """
        SENDENV FOO_1
        sendenv FOO_2
      """
    )
  }

  func testPasingOf_serverAliveCountMax () throws {
    try check(
      field: \.serverAliveCountMax,
      expected: 2,
      config: "ServerAliveCountMax 2"
    )
  }

  func testPasingOf_serverAliveInterval () throws {
    try check(
      field: \.serverAliveInterval,
      expected: 60,
      config: "ServerAliveInterval 60"
    )
  }

  func testPasingOf_setEnv () throws {
    try check(
      field: \.setEnv,
      expected: ["LANG": "C", "FOO": "bar"],
      config: """
        SetEnv FOO=bar
        setenv LANG C
      """
    )
  }

  func testPasingOf_streamLocalBindMask () throws {
    try check(
      field: \.streamLocalBindMask,
      expected: 127,
      config: "streamlocalbindmask 0177"
    )
    try check(
      field: \.streamLocalBindMask,
      expected: Int("0177", radix: 8),
      config: "streamlocalbindmask 0177"
    )
  }

  func testPasingOf_streamLocalBindUnlink () throws {
    try check(
      field: \.streamLocalBindUnlink,
      expected: .no,
      config: "streamLocalBindUnlink no"
    )
  }

  func testPasingOf_strictHostKeyChecking () throws {
    try check(
      field: \.strictHostKeyChecking,
      expected: .acceptNew,
      config: "strictHostKeyChecking accept-new "
    )
  }

  func testPasingOf_syslogFacility () throws {
    try check(
      field: \.syslogFacility,
      expected: .LOCAL7,
      config: "syslogFacility LOCAL7"
    )
    try check(
      field: \.syslogFacility,
      expected: .AUTH,
      config: "syslogFacility AUTH"
    )
  }

  func testPasingOf_tcpKeepAlive () throws {
    try check(
      field: \.tcpKeepAlive,
      expected: .yes,
      config: "tcpKeepAlive yes"
    )
  }

  func testPasingOf_tunnel () throws {
    try check(
      field: \.tunnel,
      expected: .pointToPoint,
      config: "tunnel point-to-point"
    )
  }

  func testPasingOf_tunnelDevice () throws {
    try check(
      field: \.tunnelDevice,
      expected: ssh.TunnelDevice(local: .id(0), remote: .any),
      config: "TunnelDevice 0:any"
    )
    try check(
      field: \.tunnelDevice,
      expected: ssh.TunnelDevice(local: .id(3)),
      config: "TunnelDevice 3"
    )
    try check(
      field: \.tunnelDevice,
      expected: ssh.TunnelDevice(),
      config: "TunnelDevice any:any"
    )
  }

  func testPasingOf_updateHostKeys () throws {
    try check(
      field: \.updateHostKeys,
      expected: .ask,
      config: "updateHostKeys ask"
    )
  }

  func testPasingOf_user () throws {
    try check(
      field: \.user,
      expected: "root",
      config: "USER=root"
    )
  }

  func testPasingOf_userKnownHostsFile () throws {
    try check(
      field: \.userKnownHostsFile,
      expected: ["~/.ssh/known_hosts", "~/.ssh/known_hosts.debian.org"],
      config: "UserKnownHostsFile ~/.ssh/known_hosts ~/.ssh/known_hosts.debian.org"
    )
  }

  func testPasingOf_verifyHostKeyDNS () throws {
    try check(
      field: \.verifyHostKeyDNS,
      expected: .no,
      config: "VERIFYHOSTKEYDNS no"
    )
  }

  func testPasingOf_visualHostKey () throws {
    try check(
      field: \.visualHostKey,
      expected: .no,
      config: "visualHostKey no"
    )
  }

  func testPasingOf_xAuthLocation () throws {
    try check(
      field: \.xAuthLocation,
      expected: "/opt/X11/bin/xauth",
      config: "XAuthLocation /opt/X11/bin/xauth"
    )
  }

  func testPasingOf_unknown () throws {
    try check(
      field: \.unparsed,
      expected: [
        "hello": ["WORLD"],
        "one": ["1"],
        "two": ["2"],
        "field": ["a", "b"]
      ],
      config: """
        Hello WORLD
        one 1
        twO 2
        field a
        field b
      """
    )
  }

  func testUnableToDecode () throws {
    let content = """
    Host *
      port abc
    """
    var error: Error!

    XCTAssertThrowsError(try ssh.ConfigDecoder().decode(from: content)) {
      error = $0
    }
    XCTAssertTrue(error is ssh.ConfigDecoderError)
    XCTAssertEqual(error as? ssh.ConfigDecoderError, .unableToDecode(path: "port", value: "abc", as: UInt16.self))
  }

  private func check<T> (field: WritableKeyPath<ssh.Properties, T>, expected: T, config: String) throws {
    var properties = ssh.Properties()
    properties[keyPath: field] = expected
    let expectedConfig = ssh.Config(ssh.Host("*", properties))

    let content = """
    Host *
      \(config)
    """;

    try assertConfigs(content, expectedConfig)
  }

  private func assertConfigs (_ config: String, _ expected: ssh.Config) throws {
    let decoder = ssh.ConfigDecoder()
    let actual = try decoder.decode(from: config)

    let message = """


    [config]:
    \(config)

    [expected]:
    \(try expected.toJsonString())


    [actual]:
    \(try actual.toJsonString())

    """

    XCTAssertEqual(actual, expected, message)
  }
}
