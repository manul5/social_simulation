# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :shares, dependent: :destroy

  # Scopes
  scope :real, -> { where(is_fake: false) }
  scope :fake, -> { where(is_fake: true) }

  # Validaciones
  validates :content, presence: true
  validates :is_fake, inclusion: { in: [ true, false ] }
  validates :user, presence: true


  private
end
