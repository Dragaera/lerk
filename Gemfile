source 'https://rubygems.org'

# Discord API binding
gem 'discordrb', ref: '09cbc79', git: 'https://github.com/meew0/discordrb.git'

# Prometheus metrics
gem 'rack'
gem 'prometheus-client', '~> 0.7.1'

gem 'sequel'
gem 'pg'
gem 'sequel_pg', require: 'sequel'

gem 'rake'

gem 'warning'

# Resolving Steam IDs
gem 'steam-id2', '~> 0.4.0'

# Hive 2 API binding
gem 'hive-stalker', '~> 0.1.0'
# Gorge binding
gem 'gorgerb', '~> 0.1.0'
# Formatting helper
gem 'silverball', '~> 0.1.0'

group :development do
  gem 'pry'
end

group :testing do
  gem 'rspec'
  gem 'database_cleaner'
  gem 'factory_bot'
end

group :development, :testing do
  gem 'dotenv'
end
