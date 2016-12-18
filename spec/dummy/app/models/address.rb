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

class Address < ApplicationRecord
  belongs_to :user

  scope :in_sweden, -> { where(country: 'SE') }
end
