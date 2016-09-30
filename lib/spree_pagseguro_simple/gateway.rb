require 'pag_seguro'

module SpreePagseguroSimple
  class Gateway

    def initialize(payment)
      @payment = payment
      @order = @payment.order
      @payment_method_email = @payment.payment_method.preferred_email
      @payment_method_token = @payment.payment_method.preferred_token

      process
    end

    def is_not_completed?
      !@payment.completed? && transaction_exists_and_is_loaded && @pag_seguro_transaction.state == 'pending'
    end

    def payment_url
      subdomain = @env == :sandbox ? 'sandbox.pagseguro' : 'pagseguro'
      "https://#{subdomain}.uol.com.br/v2/checkout/payment.html?code=#{@pag_seguro_transaction.code}"
    end

    private
    def process
      set_environment

      unless transaction_exists_and_is_loaded
        build_pagseguro
        create_transaction
      end
    end

    def set_environment
      @env = ENV['PAGSEGURO_ENV'] ? :production : :sandbox
      PagSeguro::Url.environment = @env
    end

    def transaction_exists_and_is_loaded
      @pag_seguro_transaction ||= Spree::PagSeguroTransaction.find_by!(order_id: @order.number)
    rescue
      false
    end

    def create_transaction
      Spree::PagSeguroTransaction.create!(email: @order.email, amount: @order.total, order_id: @order.number, code: @pagseguro.code, state: 'pending')
    end

    def build_pagseguro
      redirect_url     = "#{Spree::Store.default.url}/pagseguro/callback?order=#{@order.number}"
      notification_url = "#{Spree::Store.default.url}/pagseguro/notify"
      customer_name = [@order.bill_address.firstname, @order.bill_address.lastname].join(' ')
      customer_email = @order.email
      customer_ddd = @order.bill_address.phone.gsub(/\D/,'')[0..1] if @order.bill_address.phone
      customer_phone = @order.bill_address.phone.gsub(/\D/,'') if @order.bill_address.phone
      address = [@order.bill_address.address1, @order.bill_address.address2].join(' ')
      city = @order.bill_address.city
      postal_code = @order.bill_address.zipcode
      state = @order.bill_address.state.nil? ? @order.bill_address.state_name.to_s : @order.bill_address.state.abbr

      @pagseguro = ::PagSeguro::Payment.new(@payment_method_email, @payment_method_token,
                                            extra_amount: (@order.total - @order.item_total).round(2), id: @order.number,
                                            notification_url: notification_url, redirect_url: redirect_url)

      @pagseguro.items = @order.line_items.map do |item|
        product              = ::PagSeguro::Item.new
        product.id           = item.id
        product.description  = item.variant.name
        product.amount       = item.price.round(2)
        product.weight       = (item.variant.weight * 1000).to_i if item.variant.weight.present?
        product.quantity     = item.quantity
        product
      end

      @pagseguro.sender = ::PagSeguro::Sender.new(
        name: customer_name, email: customer_email,
        phone_ddd: customer_ddd, phone_number: customer_phone)

      @pagseguro.shipping = ::PagSeguro::Shipping.new(
        type: ::PagSeguro::Shipping::UNIDENTIFIED, state: (state ? state : nil),
        city: city, postal_code: postal_code, street: address)

      @pagseguro
    end

  end
end
