$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

Dotenv.load

require 'config/lerk'
require 'config/database'

require 'lerk'
