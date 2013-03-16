task :default => [:test, :build]
task :readme do
  readme = `bin/ipod help`

  readme += <<-__

[![Build Status](https://travis-ci.org/artm/ipod_db.png)](https://travis-ci.org/artm/ipod_db)

  __

  %w(sync ls rm).each do |subcommand|
    title = "SUBCOMMAND: #{subcommand}"
    readme += "\n#{title}\n#{"=" * title.length}\n\n"

    rejecting = false
    rejects = %w(name author)
    readme += `bin/ipod #{subcommand} -h`.split("\n").reject do |line|
      if line =~ /^\w/
        rejecting = rejects.include? line.downcase
      else
        rejecting
      end
    end.join "\n"
  end

  readme += "\nHISTORY\n"
  readme += IO.read('HISTORY').split("\n").map{|s| "  #{s}"}.join("\n")

  puts readme
end

Rake::TestTask.new { |t|
  t.libs << 'spec'
  t.pattern = 'spec/*_spec.rb'
}

BEGIN {
  require 'bundler/gem_tasks'
  require 'rake/testtask'
}
