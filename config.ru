require File.expand_path('../.bundle/environment', __FILE__)

require 'sinatra'
require 'rack/cache'

set :run, false
set :environment, ENV['RACK_ENV'].to_sym

use Rack::Cache,
  :verbose => true,
  :metastore   => 'file:/tmp',
  :entitystore => 'file:/tmp'

require 'lib/server'
run Sinatra::Application
