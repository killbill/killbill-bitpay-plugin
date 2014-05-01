require 'spec_helper'

describe Killbill::Bitpay::PaymentPlugin do
  before(:each) do
    Dir.mktmpdir do |dir|
      file = File.new(File.join(dir, 'bitpay.yml'), "w+")
      file.write(<<-eos)
:bitpay:
  :test: true
# As defined by spec_helper.rb
:database:
  :adapter: 'sqlite3'
  :database: 'test.db'
      eos
      file.close

      @plugin              = Killbill::Bitpay::PaymentPlugin.new
      @plugin.logger       = Logger.new(STDOUT)
      @plugin.logger.level = Logger::INFO
      @plugin.conf_dir     = File.dirname(file)
      @plugin.kb_apis      = Killbill::Plugin::KillbillApi.new('bitpay', {})

      # Start the plugin here - since the config file will be deleted
      @plugin.start_plugin
    end
  end

  it 'should start and stop correctly' do
    @plugin.stop_plugin
  end
end
