FactoryGirl.define do
  factory :address do
    user

    street { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
  end
end

FactoryGirl.define do
  factory :micropost do
    content { Faker::Lorem.sentence }
    likes { rand(1..1000) }
    reposts { rand(1..1000) }
    status { [:draft, :published, :archived].sample }
    created_at { rand(1..1000).days.ago }

    user
  end
end

FactoryGirl.define do
  factory :relationship do
    association :follower, factory: :user
    association :followed, factory: :user
  end
end

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    factory :admin do
      admin { true }
    end
  end
end
