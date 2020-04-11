class RemoveCodeToSpreePayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :spree_payments, :code
  end
end
