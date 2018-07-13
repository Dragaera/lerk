#!/bin/bash

case "$1" in
    bot)
        echo "Starting discord bot..."
        exec ruby bin/lerk
        ;;
    *)
        echo "Don't know what to do with $1"
        echo "Valid commands: bot"
        exit 1
esac
