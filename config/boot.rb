$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

env_file = ".env.#{ APPLICATION_ENV }"
puts "Loading env-specific env variables from #{ env_file }"
Dotenv.load env_file

require 'config/lerk'
require 'config/database'

require 'lerk'
