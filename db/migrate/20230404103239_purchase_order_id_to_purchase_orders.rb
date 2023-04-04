class PurchaseOrderIdToPurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :purchase_orders, :purchase_order_id, :integer
  end
end
