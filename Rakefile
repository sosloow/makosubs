task :default => :test

desc "Run all tests"
task(:test) do
  Dir['./test/*_tests.rb'].each { |f| load f }
end
