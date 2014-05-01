module Killbill #:nodoc:
  module Bitpay #:nodoc:
    class BitpayTransaction < ::Killbill::Plugin::ActiveMerchant::ActiveRecord::Transaction

      self.table_name = 'bitpay_transactions'

      belongs_to :bitpay_response

    end
  end
end
