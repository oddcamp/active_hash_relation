require_relative './application_record'

class Address < ApplicationRecord
  belongs_to :user

  scope :in_sweden, -> { where(country: 'SE') }
end
