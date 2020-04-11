module Spree
  class PagseguroController < Spree::StoreController
    skip_before_action :verify_authenticity_token, only: :notify

    def callback
      @order = Spree::Order.find_by_number(params[:order])

      pagseguro_transaction = Spree::PagSeguroTransaction.find_by_order_id(@order.number)
      pagseguro_transaction.update_attribute :state, 'waiting'

      flash[:notice] = Spree.t(:pagseguro_transaction_success)
      redirect_to spree.order_path(@order)
    end

    def notify
      return unless request.post?
      payment_method = Spree::PaymentMethod.where(type: 'Spree::PaymentMethod::Pagseguro').last

      email = payment_method.preferred_email
      token = payment_method.preferred_token
      _notification_code = params[:notificationCode]

      notification = PagSeguro::Notification.new(email, token, _notification_code)
      @order = Spree::Order.find_by_number(notification.reference)

      payment = @order.payments.where(state: "checkout",
                                      payment_method_id: payment_method.id,
                                      amount: notification.gross_amount).last

      pag_seguro_transaction = Spree::PagSeguroTransaction.find_by_order_id @order.number

      if payment
        ActiveRecord::Base.transaction do
          if notification.approved?
            payment.complete!

            if pag_seguro_transaction.present?
              pag_seguro_transaction.update!(state: 'approved')
            end
          end

          if notification.cancelled? || notification.returned?
            payment.void!

            if pag_seguro_transaction.present?
              pag_seguro_transaction.update!(state: 'cancelled')
            end
          end
        end
      else
        raise StandardError
      end

      render body: :ok
    end
  end
end
