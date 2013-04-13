lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require  'ipod_db/version'

Gem::Specification.new do |s|
  s.name = 'ipod_db'
  s.version = IpodDB::VERSION
  s.summary = 'ipod database access'
  s.description = 'Access iPod Shuffle 2nd gen from ruby'
  s.author = 'Artem Baguinski'
  s.email = 'femistofel@gmail.com'
  s.homepage = 'https://github.com/artm/ipod_db'
  s.license = 'Public Domain'

  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'bindata'
  s.add_runtime_dependency 'map'
  s.add_runtime_dependency 'main'
  s.add_runtime_dependency 'smart_colored'
  s.add_runtime_dependency 'taglib-ruby'
  s.add_runtime_dependency 'ruby-progressbar'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'activesupport'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler', '~> 1.3'
  # not sure where this belongs, they are part of my development process
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'rb-inotify'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'libnotify'
end
