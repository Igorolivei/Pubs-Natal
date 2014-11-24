source 'http://rubygems.org' 

#ruby '1.9.3'

gem 'sinatra'
gem 'sinatra-activerecord'

group :production, :staging do
  gem "pg"
end

group :development, :test do
  gem "sqlite3-ruby", "~> 1.3.0", :require => "sqlite3"
end
