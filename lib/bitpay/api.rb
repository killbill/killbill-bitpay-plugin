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

      def authorize_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def capture_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def purchase_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
        kb_tenant_id                     = context.tenant_id
        kb_payment_transaction           = get_kb_transaction(kb_payment_id, kb_payment_transaction_id, kb_tenant_id)
        payment_transaction_external_key = kb_payment_transaction.external_key

        response = @response_model.where("transaction_type = 'PURCHASE' AND kb_tenant_id = '#{kb_tenant_id}' AND authorization = '#{payment_transaction_external_key}'")
                                  .order(:created_at)[0]

        transaction = response.create_bitpay_transaction(:kb_account_id                => kb_account_id,
                                                         :kb_tenant_id                 => kb_tenant_id,
                                                         :amount_in_cents              => amount.nil? ? nil : to_cents(amount, currency),
                                                         :currency                     => currency,
                                                         :api_call                     => :purchase,
                                                         :kb_payment_id                => kb_payment_id,
                                                         :kb_payment_transaction_id    => kb_payment_transaction_id,
                                                         :transaction_type             => response.transaction_type,
                                                         :payment_processor_account_id => response.payment_processor_account_id,
                                                         :txn_id                       => response.txn_id,
                                                         :bitpay_response_id           => response.id)

        response.to_transaction_info_plugin(transaction)
      end

      def void_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, properties, context)
      end

      def credit_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def refund_payment(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, kb_payment_transaction_id, kb_payment_method_id, amount, currency, properties, context)
      end

      def get_payment_info(kb_account_id, kb_payment_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_id, properties, context)
      end

      def search_payments(search_key, offset, limit, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(search_key, offset, limit, properties, context)
      end

      def add_payment_method(kb_account_id, kb_payment_method_id, payment_method_props, set_default, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_method_id, payment_method_props, set_default, properties, context)
      end

      def delete_payment_method(kb_account_id, kb_payment_method_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_method_id, properties, context)
      end

      def get_payment_method_detail(kb_account_id, kb_payment_method_id, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, kb_payment_method_id, properties, context)
      end

      def set_default_payment_method(kb_account_id, kb_payment_method_id, properties, context)
        # TODO
      end

      def get_payment_methods(kb_account_id, refresh_from_gateway, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(kb_account_id, refresh_from_gateway, properties, context)
      end

      def search_payment_methods(search_key, offset, limit, properties, context)
        # Pass extra parameters for the gateway here
        options = {}

        properties = merge_properties(properties, options)
        super(search_key, offset, limit, properties, context)
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
            :account_id => config[:bitpay][:api_key],
            # Overload the order_id (passed as posData) (TODO fix OffsitePayments implementation)
            :order_id => "#{kb_account_id};#{context.tenant_id}"
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
          is_success = nil
          if service.status == 'Completed'
            is_success = true
          elsif service.status == 'Failed'
            is_success = false
          end

          if is_success.nil?
            # Either the invoice was never paid (expired) or hasn't been confirmed yet
            logger.info "Ignoring BitPay IPN #{service.raw}"
          else
            # See above (parsed from posData)
            kb_account_id, kb_tenant_id = service.item_id.nil? ? nil : service.item_id.split(';')
            amount = service.params['price']
            currency = service.currency
            payment_external_key = service.transaction_id
            payment_transaction_external_key = service.transaction_id

            payment = record_payment(kb_account_id, kb_tenant_id, amount, currency, is_success, payment_external_key, payment_transaction_external_key)
            gw_notification.kb_payment_id = payment.id unless payment.nil?
          end
        end
      end

      def record_payment(kb_account_id, kb_tenant_id, amount, currency, is_success, payment_external_key, payment_transaction_external_key, kb_payment_method_id=nil)
        if kb_account_id.nil? || kb_tenant_id.nil? || amount.nil? || currency.nil? || payment_transaction_external_key.nil?
          @logger.warn "Invalid notification: kb_account_id=#{kb_account_id}, kb_tenant_id=#{kb_tenant_id}, amount=#{amount}, currency=#{currency}, payment_external_key=#{payment_external_key}, payment_transaction_external_key=#{payment_transaction_external_key}, kb_payment_method_id=#{kb_payment_method_id}"
          return nil
        else
          @logger.info "Recording payment: kb_account_id=#{kb_account_id}, amount=#{amount}, currency=#{currency}, payment_external_key=#{payment_external_key}, payment_transaction_external_key=#{payment_transaction_external_key}, kb_payment_method_id=#{kb_payment_method_id}"
        end

        @response_model.create(:api_call         => :purchase,
                               :kb_account_id    => kb_account_id,
                               :transaction_type => :PURCHASE,
                               :authorization    => payment_transaction_external_key,
                               :kb_tenant_id     => kb_tenant_id,
                               :success          => is_success)

        context = @kb_apis.create_context(kb_tenant_id)
        kb_account = @kb_apis.account_user_api.get_account_by_id(kb_account_id, context)
        kb_payment_method_id = kb_payment_method_id.nil? ? kb_account.payment_method_id : kb_payment_method_id
        kb_payment_id = nil
        properties = {}
        @kb_apis.payment_api.create_purchase(kb_account,
                                             kb_payment_method_id,
                                             kb_payment_id,
                                             amount,
                                             currency,
                                             payment_external_key,
                                             payment_transaction_external_key,
                                             properties,
                                             context)
      end

      def get_active_merchant_module
        ::OffsitePayments.integration(:bit_pay)
      end
    end
  end
end
