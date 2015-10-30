killbill-bitpay-plugin
======================

Plugin to use [BitPay](http://www.bitpay.com/) as a gateway.

Release builds are available on [Maven Central](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.kill-bill.billing.plugin.ruby%22%20AND%20a%3A%22bitpay-plugin%22) with coordinates `org.kill-bill.billing.plugin.ruby:bitpay-plugin`.

Kill Bill compatibility
-----------------------

| Plugin version | Kill Bill version |
| -------------: | ----------------: |
| 0.0.y          | 0.14.z            |

Requirements
------------

The plugin needs a database. The latest version of the schema can be found here: https://raw.github.com/killbill/killbill-bitpay-plugin/master/db/ddl.sql.

Usage
-----

Add a payment method:

```
curl -v \
     -u admin:password \
     -H "X-Killbill-ApiKey: bob" \
     -H "X-Killbill-ApiSecret: lazar" \
     -H "Content-Type: application/json" \
     -H "X-Killbill-CreatedBy: demo" \
     -X POST \
     --data-binary '{
       "pluginName": "killbill-bitpay",
       "pluginInfo": {}
     }' \
     "http://127.0.0.1:8080/1.0/kb/accounts/<ACCOUNT_ID>/paymentMethods?isDefault=true&pluginProperty=skip_gw=true"
```

Notes:
* Make sure to replace *ACCOUNT_ID* with the id of the Kill Bill account
* `skip_gw=true` is required because BitPay doesn't store any information to trigger payments

To generate a BitPay invoice:

```
curl -v \
     -u admin:password \
     -H "X-Killbill-ApiKey: bob" \
     -H "X-Killbill-ApiSecret: lazar" \
     -H "Content-Type: application/json" \
     -H "X-Killbill-CreatedBy: demo" \
     -X POST \
     --data-binary '{
       "formFields": [
         {
           "key": "notify_url",
           "value": "<NOTIFY_URL>"
         },
         {
           "key": "amount",
           "value": 0.12345
         },
         {
           "key": "currency",
           "value": "BTC"
         }
       ]
     }' \
     "http://127.0.0.1:8080/1.0/kb/paymentGateways/hosted/form/<ACCOUNT_ID>"
```

Notes:
* Make sure to replace *ACCOUNT_ID* with the id of the Kill Bill account
* Change *NOTIFY_URL* to your publicly accessible endpoint which will process BitPay Instant Payment Notifications (IPN)
* The response will contain the invoice id. The user should then be redirected to `https://bitpay.com/invoice/<INVOICE_ID>`
* At this point, no payment has been created in Kill Bill. The payment will be recorded when processing the notification

You can simulate a notification as follows:

```
curl -v \
     -u admin:password \
     -H "X-Killbill-ApiKey: bob" \
     -H "X-Killbill-ApiSecret: lazar" \
     -H "Content-Type: application/json" \
     -H "X-Killbill-CreatedBy: demo" \
     -X POST \
     --data-binary '{
       "id": "<INVOICE_ID>"
     }' \
     "http://127.0.0.1:8080/1.0/kb/paymentGateways/notification/killbill-bitpay"
```

Notes:

* Replace *INVOICE_ID* with the actual BitPay invoice id
* If *status* is *complete*, a successful payment will be recorded
* If *status* is *invalid*, a failed payment will be recorded
* Otherwise, no payment is recorded (either the user didn't pay, or it is not yet confirmed)

You can verify the payment via:

```
curl -v \
     -u admin:password \
     -H "X-Killbill-ApiKey: bob" \
     -H "X-Killbill-ApiSecret: lazar" \
     "http://127.0.0.1:8080/1.0/kb/accounts/<ACCOUNT_ID>/payments?withPluginInfo=true"
```

Notes:
* Make sure to replace *ACCOUNT_ID* with the id of the Kill Bill account
