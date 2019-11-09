#! /usr/bin/env ruby

$LOAD_PATH.unshift '.'

require 'config/boot'

run Lerk::Web::Interface
