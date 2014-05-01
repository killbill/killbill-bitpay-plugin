require 'spec_helper'

ActiveMerchant::Billing::Base.mode = :test

describe Killbill::Bitpay::PaymentPlugin do

  include ::Killbill::Plugin::ActiveMerchant::RSpec

  before(:each) do
    @plugin = Killbill::Bitpay::PaymentPlugin.new

    @account_api    = ::Killbill::Plugin::ActiveMerchant::RSpec::FakeJavaUserAccountApi.new
    svcs            = {:account_user_api => @account_api}
    @plugin.kb_apis = Killbill::Plugin::KillbillApi.new('bitpay', svcs)

    @plugin.logger       = Logger.new(STDOUT)
    @plugin.logger.level = Logger::INFO
    @plugin.conf_dir     = File.expand_path(File.dirname(__FILE__) + '../../../../')
    @plugin.start_plugin
  end

  after(:each) do
    @plugin.stop_plugin
  end

  it 'should generate invoices correctly' do
    kb_account_id = SecureRandom.uuid
    kb_tenant_id  = SecureRandom.uuid
    context       = @plugin.kb_apis.create_context(kb_tenant_id)
    fields        = @plugin.hash_to_properties({
                                                   :order_id => '1234',
                                                   :amount   => 0.0001,
                                                   :currency => 'BTC'
                                               })
    form          = @plugin.build_form_descriptor kb_account_id, fields, [], context

    form.kb_account_id.should == kb_account_id
    form.form_method.should == 'GET'
    form.form_url.should == 'https://bitpay.com/invoice'

    form_fields = @plugin.properties_to_hash(form.form_fields)
    form_fields.size.should == 1
    form_fields[:id].should_not be_nil
    @plugin.logger.info "Invoice at https://bitpay.com/invoice?id=#{form_fields[:id]}"

    notification    = {
        "id"             => "#{form_fields[:id]}",
        "orderID"        => "1234",
        "url"            => "https://bitpay.com/invoice/#{form_fields[:id]}",
        "status"         => "new",
        "btcPrice"       => "0.0001",
        "price"          => "0.0001",
        "currency"       => "BTC",
        "posData"        => '{"orderId":"1234}'
    }.to_json
    gw_notification = @plugin.process_notification notification, [], context
    gw_notification.should_not be_nil
    # We cannot fully check it though because of the acknowledge implementation (requires timestamps checking)
  end
end
