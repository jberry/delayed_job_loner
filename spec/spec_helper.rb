RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.mock_with(:rspec) { |c| c.syntax = [:expect, :should] }
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
end
