module Lerk
  module Config
    module Database
      def self.database
        opts = {}
        opts[:adapter]  = ADAPTER
        opts[:host]     = HOST     if HOST
        opts[:port]     = PORT     if PORT
        opts[:database] = DATABASE if DATABASE
        opts[:user]     = USER     if USER
        opts[:password] = PASS     if PASS
        opts[:test]     = true

        Sequel.connect(opts)
      end
    end
  end
end

# Needs to be loaded before other extensions, in case they provide custom
# migration methods, which will only be loaded if the migration extension is loaded.
Sequel.extension :migration

# Automated created at / updated at timestamps.
Sequel::Model.plugin :timestamps

DB = Lerk::Config::Database.database
Sequel::Model.db = DB

begin
  DatabaseCleaner[:sequel].db = DB
rescue NameError
end
