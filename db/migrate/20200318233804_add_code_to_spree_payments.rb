class AddCodeToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_payments, :code, :string
  end
end
