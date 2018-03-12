class CreateEbayProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :ebay_products do |t|
      t.string :link
      t.string :status

      t.timestamps
    end
  end
end
