# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
  has_many :shares, dependent: :destroy

  # Scopes
  scope :real, -> { where(is_fake: false) }
  scope :fake, -> { where(is_fake: true) }
  scope :viral, -> { where("viral_score > ?", 1.2) }

  # Validaciones
  validates :content, presence: true
  validates :is_fake, inclusion: { in: [ true, false ] }
  validates :user, presence: true

  # Callback para viral_score
  before_validation :set_default_viral_score, on: :create

  private

  def set_default_viral_score
    self.viral_score ||= rand(0.7..1.3)
  end
end
