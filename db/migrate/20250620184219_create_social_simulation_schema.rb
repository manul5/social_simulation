class CreateSocialSimulationSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.float :bias, null: false
      t.timestamps
    end

    create_table :posts do |t|
      t.string :content, null: false
      t.boolean :is_fake, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.timestamps
    end
  end
end
