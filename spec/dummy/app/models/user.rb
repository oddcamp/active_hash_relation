# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  name             :string
#  email            :string           not null
#  admin            :boolean          default("false")
#  verified         :boolean          default("false")
#  token            :string           not null
#  microposts_count :integer          default("0"), not null
#  followers_count  :integer          default("0"), not null
#  followings_count :integer          default("0"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

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
