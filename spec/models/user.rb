require_relative './application_record'

class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_one :address

  before_validation :ensure_token

  scope :unverified, -> {where(verified: false)}
  scope :unsocial, -> {where(followings_count: 0, followers_count: 0)}
  scope :created_on, ->(date) {where("date(created_at) = ?", date.to_date)}

  private
    def ensure_token
      self.token = generate_hex(:token) unless token.present?
    end

    def generate_hex(column)
      loop do
        hex = SecureRandom.hex
        break hex unless self.class.where(column => hex).any?
      end
    end
end
