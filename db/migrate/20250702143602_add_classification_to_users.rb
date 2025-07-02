class AddClassificationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :classification, :string
  end
end
