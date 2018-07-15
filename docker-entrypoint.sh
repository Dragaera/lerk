#!/bin/bash

case "$1" in
    bot)
        echo "Starting discord bot..."
        exec ruby bin/lerk
        ;;
    migrate)
        echo "Applying database migrations"
        exec rake db:migrate
    *)
        echo "Don't know what to do with $1"
        echo "Valid commands: bot, migrate"
        exit 1
esac
