module Spree
  class PagSeguroTransaction < ActiveRecord::Base
    has_many :payments, :as => :source

    def self.update_last_transaction(params)
    end

  end
end
