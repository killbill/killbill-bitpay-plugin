module Killbill #:nodoc:
  module Bitpay #:nodoc:
    class BitpayResponse < ::Killbill::Plugin::ActiveMerchant::ActiveRecord::Response

      self.table_name = 'bitpay_responses'

      has_one :bitpay_transaction

      def self.from_response(api_call, kb_account_id, kb_payment_id, kb_tenant_id, response, extra_params = {})
        super(api_call,
              kb_account_id,
              kb_payment_id,
              kb_tenant_id,
              response,
              {
                  # Pass custom key/values here
                  #:params_id => extract(response, 'id'),
                  #:params_card_id => extract(response, 'card', 'id')
              }.merge!(extra_params),
              ::Killbill::Bitpay::BitpayResponse)
      end
    end
  end
end
