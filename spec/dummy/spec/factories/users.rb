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

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    factory :admin do
      admin { true }
    end
  end
end

