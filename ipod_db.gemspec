Gem::Specification.new do |s|
  s.name = 'ipod_db'
  s.version = '0.2.2'
  s.date = '2013-03-16'
  s.summary = 'ipod database access'
  s.description = 'Access iPod Shuffle 2nd gen from ruby'
  s.author = 'Artem Baguinski'
  s.email = 'femistofel@gmail.com'
  s.homepage = 'https://github.com/artm/ipod_db'

  s.executables = %w(ipod)
  s.require_path = 'lib'
  s.files =
    %w(Rakefile
       README
       HISTORY
       LICENSE
       ipod_db.gemspec

       bin/ipod

       lib/ipod_db.rb
       lib/ipod_db/version.rb
       lib/pretty.rb
       lib/bindata/itypes.rb

       spec/spec_helper.rb
       spec/ipod_db_spec.rb

       test_data.rb
       test_data/iPod_Control/iTunes/iTunesShuffle
       test_data/iPod_Control/iTunes/iTunesStats
       test_data/iPod_Control/iTunes/iTunesDB.ext
       test_data/iPod_Control/iTunes/iTunesSD
       test_data/iPod_Control/iTunes/iTunesPState
       test_data/iPod_Control/iTunes/iTunesDB)

  s.add_runtime_dependency 'bindata'
  s.add_runtime_dependency 'map'
  s.add_runtime_dependency 'main'
  s.add_runtime_dependency 'smart_colored'
  s.add_runtime_dependency 'taglib-ruby'
  s.add_runtime_dependency 'ruby-progressbar'
  s.add_runtime_dependency 'highline'

  s.add_development_dependency 'purdytest'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'rb-inotify'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'libnotify'
end
