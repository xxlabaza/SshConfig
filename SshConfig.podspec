Pod::Spec.new do |s|
  s.name = 'SshConfig'
  s.version = '1.0.1'
  s.summary = 'An SSH config parser library with a fancy API'
  s.description  = <<-EOS
  The SshConfig makes it quick and easy to load, parse, and
  decode/encode the SSH configs. It also helps to resolve the
  properties by hostname and use them safely in your apps
  (thanks for Optional and static types in Swift).

  Instructions for installation are in [the README](https://github.com/xxlabaza/SshConfig).
  EOS

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  s.swift_versions = ['5.1', '5.2', '5.3', '5.4']

  s.homepage = 'https://github.com/xxlabaza/SshConfig'
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.author = { 'Artem Labazin' => 'xxlabaza@gmail.com' }

  s.source = { :git => 'https://github.com/xxlabaza/SshConfig.git', :tag => s.version }
  s.documentation_url = 'https://xxlabaza.github.io/SshConfig/'

  s.source_files = 'Sources/SshConfig/**/*.swift'
end
