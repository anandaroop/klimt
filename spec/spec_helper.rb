require 'bundler/setup'
require 'klimt'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub_netrc_authentication
  creds = { 'api.artsy.biz' => ['somebody@artsymail.com', 'some-token-123'] }
  stub_const("#{described_class.name}::HOSTS", test: 'api.artsy.biz')
  allow(Netrc).to receive(:read).and_return(creds)
end
