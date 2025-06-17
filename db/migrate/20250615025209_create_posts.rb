class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :content
      t.boolean :is_fake
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
