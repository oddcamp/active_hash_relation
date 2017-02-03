require_relative './application_record'

class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: :followings_count
  belongs_to :followed, class_name: "User", counter_cache: :followers_count

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
