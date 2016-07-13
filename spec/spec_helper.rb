require 'simplecov'
require 'yaml'
require 'json'
SimpleCov.start do
  add_filter "spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sanitizer'
require 'desanitizer'

