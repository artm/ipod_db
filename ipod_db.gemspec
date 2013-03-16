load
Gem::Specification.new do |s|
  s.name = 'ipod_db'
  s.version = '0.2.1'
  s.date = '2013-03-16'
  s.summary = 'ipod database access'
  s.description = 'Access iPod Shuffle 2nd gen from ruby'
  s.author = 'Artem Baguinski'
  s.email = 'femistofel@gmail.com'
  s.files =
    %w(ipod
       Rakefile
       README
       HISTORY
       LICENSE
       ipod_db.gemspec

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
  s.executables = %w(ipod)
  s.require_path = 'lib'

  s.homepage = 'https://github.com/artm/ipod_db'
end
