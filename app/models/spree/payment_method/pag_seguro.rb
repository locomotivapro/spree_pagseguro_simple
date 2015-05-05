module Spree
  class PaymentMethod::PagSeguro < PaymentMethod
    preference :email, :string
    preference :token, :string

    def payment_profiles_supported?
      false
    end

    def supports?(source)
      true
    end

    def provider_class
      Billing::Pagseguro
    end

    def provider
      provider_class.new
    end

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    def method_type
      'pag_seguro'
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def cancel(response); end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def actions
      %w(capture void)
    end

  end
end
