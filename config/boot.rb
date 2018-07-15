$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

# Ignore all warnings about uninitialized instane variables, as `sequel`
# generates plenty of those.
Warning.ignore(/instance variable @\w+ not initialized/)

env_file = ".env.#{ APPLICATION_ENV }"
puts "Loading env-specific env variables from #{ env_file }"
Dotenv.load env_file

require 'config/lerk'
require 'config/database'

require 'lerk'
