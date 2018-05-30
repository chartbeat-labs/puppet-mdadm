RSpec.configure do |c|
    c.mock_with :mocha
end
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts
