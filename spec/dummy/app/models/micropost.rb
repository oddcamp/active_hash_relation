# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  user_id    :integer          not null
#  likes      :integer          default("0"), not null
#  reposts    :integer          default("0"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_microposts_on_user_id  (user_id)
#

class Micropost < ApplicationRecord
  belongs_to :user, counter_cache: true

  scope :created_on, ->(date) {where("date(microposts.created_at) = ?", date.to_date)}
end
