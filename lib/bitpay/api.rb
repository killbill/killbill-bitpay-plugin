module Killbill #:nodoc:
  module Bitpay #:nodoc:
    class PaymentPlugin < ::Killbill::Plugin::ActiveMerchant::PaymentPlugin

      def initialize
        gateway_builder = Proc.new do |config|
          nil
        end

        super(gateway_builder,
              :bitpay,
              ::Killbill::Bitpay::BitpayPaymentMethod,
              ::Killbill::Bitpay::BitpayTransaction,
              ::Killbill::Bitpay::BitpayResponse)
      end

      def authorize_payment(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def capture_payment(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def void_payment(kb_account_id, kb_payment_id, kb_payment_method_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_method_id, properties, context)
      end

      def process_payment(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def get_payment_info(kb_account_id, kb_payment_id, properties, context)
        super
      end

      def search_payments(search_key, offset, limit, properties, context)
        super
      end

      def process_refund(kb_account_id, kb_payment_id, refund_amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, refund_amount, currency, properties, context)
      end

      def get_refund_info(kb_account_id, kb_payment_id, properties, context)
        super
      end

      def search_refunds(search_key, offset, limit, properties, context)
        super
      end

      def add_payment_method(kb_account_id, kb_payment_method_id, payment_method_props, set_default, properties, context)
        # Nothing to do
      end

      def delete_payment_method(kb_account_id, kb_payment_method_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_method_id, properties, context)
      end

      def get_payment_method_detail(kb_account_id, kb_payment_method_id, properties, context)
        super
      end

      def set_default_payment_method(kb_account_id, kb_payment_method_id, properties, context)
        # TODO
      end

      def get_payment_methods(kb_account_id, refresh_from_gateway, properties, context)
        super
      end

      def search_payment_methods(search_key, offset, limit, properties, context)
        super
      end

      def reset_payment_methods(kb_account_id, payment_methods, properties, context)
        super
      end

      def build_form_descriptor(kb_account_id, descriptor_fields, properties, context)
        # Pass extra parameters for the gateway here
        options = {}
        properties = merge_properties(properties, options)

        # Add the BitPay API key to generate the invoice id
        options = {
            :account_id => config[:bitpay][:api_key]
        }
        descriptor_fields = merge_properties(descriptor_fields, options)

        super(kb_account_id, descriptor_fields, properties, context)
      end

      def process_notification(notification, properties, context)
        # Add the BitPay API key to retrieve the invoice
        options = {
            :credential1 => config[:bitpay][:api_key]
        }
        properties = merge_properties(properties, options)

        super(notification, properties, context) do |gw_notification, service|
          # Retrieve the payment
          # gw_notification.kb_payment_id =
          #
          # Set the response body
          # gw_notification.entity =
        end
      end

      def get_active_merchant_module
        ::ActiveMerchant::Billing::Integrations::BitPay
      end
    end
  end
end
