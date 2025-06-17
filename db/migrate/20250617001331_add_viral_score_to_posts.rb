class AddViralScoreToPosts < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:posts, :viral_score)
      add_column :posts, :viral_score, :float, default: -> { 'random() * 0.8 + 0.7' }
      add_index :posts, :viral_score
      Post.where(viral_score: nil).update_all("viral_score = random() * 0.8 + 0.7")
    end
  end

  def down
    remove_column :posts, :viral_score if column_exists?(:posts, :viral_score)
  end
end
