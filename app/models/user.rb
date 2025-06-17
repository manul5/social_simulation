class User < ApplicationRecord
  has_many :posts, dependent: :destroy  # Asegura la relación
  has_many :shares
end
