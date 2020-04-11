module Spree::CheckoutControllerDecorator
  def self.prepended(base)
    base.before_action :create_pag_seguro_transaction, only: :edit
  end

  def create_pag_seguro_transaction
    return unless params[:state] == "payment"
    payment = @order.payments.build(payment_method: Spree::PaymentMethod.where(type: 'Spree::PaymentMethod::Pagseguro').last)
    SpreePagseguroSimple::Gateway.new(payment)
    @pag_seguro_payment = Spree::PagSeguroTransaction.find_by_order_id @order.number
  end
end

::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
