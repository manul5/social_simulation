class FixPostUserAssociation < ActiveRecord::Migration[8.0]
  def change
    # Solo añade la foreign key si no existe
    unless foreign_key_exists?(:posts, :users)
      add_foreign_key :posts, :users
    end
  end
end
