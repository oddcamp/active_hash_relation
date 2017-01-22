# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  street     :string
#  city       :string
#  country    :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_addresses_on_user_id  (user_id) UNIQUE
#

FactoryGirl.define do
  factory :address do
    user

    street { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
  end
end
