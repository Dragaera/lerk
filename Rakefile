$LOAD_PATH.unshift '.'

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    # Don't load models when executing DB migrations.
    # This is required, since some of the tables they refer to might not exist
    # yet. It also prevents accidentally using them within migrations - which
    # is asking for trouble anyway.
    ENV['LERK_SKIP_MODELS'] = '1'
    require 'config/boot'

    require 'lib/lerk'

    Sequel.extension :migration
    db = Sequel::Model.db
    if args[:version]
      Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
    else
      Sequel::Migrator.run(db, "db/migrations")
    end
  end
end

namespace :spec do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:all) do |t|
      t.fail_on_error = false
      t.rspec_opts = '--format doc'
    end

    RSpec::Core::RakeTask.new(:models) do |t|
      t.fail_on_error = false
      t.pattern       = 'spec/lerk/models/**/*_spec.rb'
      t.rspec_opts = '--format doc'
    end
  rescue LoadError
    # no rspec available
  end
end
