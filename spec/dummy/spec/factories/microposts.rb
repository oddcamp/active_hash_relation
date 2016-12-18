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

FactoryGirl.define do
  factory :micropost do
    content { Faker::Lorem.sentence }
    likes { rand(1..1000) }
    reposts { rand(1..1000) }
    created_at { rand(1..1000).days.ago }

    user
  end
end
