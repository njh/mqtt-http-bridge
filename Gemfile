source "https://rubygems.org"
ruby File.read('.ruby-version').chomp

gem 'thin'

gem 'sinatra'
gem 'mqtt', '>=0.0.7'

group :development do
  gem 'rake'
  gem 'shotgun'
end

group :test do
  gem 'rspec', '>=3.10.0'
  gem 'rack-test', :require => 'rack/test'
end
