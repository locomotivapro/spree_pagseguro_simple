module Spree
  class PagseguroController < Spree::StoreController
    skip_before_action :verify_authenticity_token, only: :notify

    def callback
      @order = Spree::Order.find_by_number(params[:order])

      pagseguro_transaction = Spree::PagseguroTransaction.find_by_order_id(@order.number)
      pagseguro_transaction.update_attribute :state, 'waiting'

      redirect_to spree.order_path(@order)
    end

    def notify
      logger.info "[PAGSEGURO] Gateway is calling /notify"
      logger.info params

      #notification = Spree::PagseguroTransaction.update_last_transaction(params)
      #payment_method = Spree::PaymentMethod.where(type: 'Spree::Gateway::PagSeguro').first

      @order = Spree::Order.find_by_number(notification.reference)
      payment = @order.payments.where(:state => "checkout",
                                      :payment_method_id => payment_method.id).last

      if notification.approved?
        logger.info "[PAGSEGURO] Order #{@order.number} approved"
        payment.complete!
      else
        logger.info "[PAGSEGURO] Order #{@order.number} failed"
        payment.failure!
      end

      render nothing: true, head: :ok
    end

  end
end
