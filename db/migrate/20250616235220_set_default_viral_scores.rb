# db/migrate/[timestamp]_set_default_viral_scores.rb
class SetDefaultViralScores < ActiveRecord::Migration[8.0]
  def up
    # Primero cambia la columna para permitir null (si no lo está)
    change_column_null :posts, :viral_score, true

    # Luego actualiza todos los posts existentes
    Post.where(viral_score: nil).find_each do |post|
      post.update(viral_score: rand(0.7..1.3))
    end

    # Finalmente establece el valor por defecto y rechaza nulls
    change_column_default :posts, :viral_score, -> { "random() * 0.6 + 0.7" }
    change_column_null :posts, :viral_score, false
  end

  def down
    change_column_null :posts, :viral_score, true
    change_column_default :posts, :viral_score, nil
  end
end
