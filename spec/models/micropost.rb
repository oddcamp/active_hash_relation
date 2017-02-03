require_relative './application_record'

class Micropost < ApplicationRecord
  belongs_to :user, counter_cache: true

  enum status: {draft: 0, published: 1, archived: 2 }

  scope :created_on, ->(date) {where("date(microposts.created_at) = ?", date.to_date)}
end
