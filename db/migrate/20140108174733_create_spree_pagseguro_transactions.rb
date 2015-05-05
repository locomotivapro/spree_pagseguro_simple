class CreateSpreePagSeguroTransactions < ActiveRecord::Migration
  def change
    create_table :spree_pag_seguro_transactions do |t|
      t.string :email
      t.float :amount
      t.string :transaction_id
      t.string :customer_id
      t.string :order_id
      t.string :payment_id
      t.text :params
      t.string :code
      t.string :state

      t.timestamps
    end
  end
end
