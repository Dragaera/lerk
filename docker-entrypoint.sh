#!/bin/bash

if [ -z "$APPLICATION_ENV" ]; then
    export APPLICATION_ENV=production
fi
echo "APPLICATION_ENV=$APPLICATION_ENV"

case "$1" in
    application)
        echo "Starting application server..."
        exec bundle exec puma -C config/puma.rb
        ;;
    bot)
        echo "Starting discord bot..."
        exec bundle exec ruby bin/lerk
        ;;
    migrate)
        echo "Applying database migrations"
        exec bundle exec rake db:migrate
        ;;
    *)
        echo "Don't know what to do with $1"
        echo "Valid commands: application, bot, migrate"
        exit 1
esac
