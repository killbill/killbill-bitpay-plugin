module Killbill #:nodoc:
  module Bitpay #:nodoc:
    class PrivatePaymentPlugin < ::Killbill::Plugin::ActiveMerchant::PrivatePaymentPlugin
      def initialize(session = {})
        super(:bitpay,
              ::Killbill::Bitpay::BitpayPaymentMethod,
              ::Killbill::Bitpay::BitpayTransaction,
              ::Killbill::Bitpay::BitpayResponse,
              session)
      end
    end
  end
end
