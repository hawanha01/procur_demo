class CreatePurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_orders do |t|
      t.string :vendor
      t.string :product

      t.timestamps
    end
  end
end
