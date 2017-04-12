ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# Adding FFaker
require 'ffaker'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Custom json helpers
  config.include Requests::JsonHelpers, type: :request
  # Custom Header helpers
  config.include Requests::HeaderHelpers, type: :request
  # Allowing Jbuilder
  config.render_views = true
  # Including Factory Girl Rails
  config.include FactoryGirl::Syntax::Methods
  # Including the Devise Helpers to help with the token
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Clean the directories with the uploaded images
  config.after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/"]) if Rails.env.test?
    FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/"]) if Rails.env.test?
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
