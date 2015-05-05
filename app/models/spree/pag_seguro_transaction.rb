module Spree
  class PagSeguroTransaction < ActiveRecord::Base
    has_many :payments, :as => :source

  end
end
