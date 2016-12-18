require 'rails_helper'

describe ActiveHashRelation do
  include Helpers

  context 'aggregations' do
    context 'min' do
      before do
        FactoryGirl.create_list(:micropost, 10)
      end

      it "one aggregation" do
        hash = { aggregate: {likes: {min: true} } }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            min: Micropost.pluck(:likes).min
          }
        })
        expect(aggregations).to eq expected_aggregations
      end
      it "multiple aggregations" do
        hash = {
          aggregate: {
            likes: {min: true}, reposts: {min: true}, created_at: {min: true}
          }
        }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            min: Micropost.pluck(:likes).min
          },
          reposts: {
            min: Micropost.pluck(:reposts).min
          },
          created_at: {
            min: Micropost.pluck(:created_at).min.to_time
          }
        })
        expect(aggregations).to eq expected_aggregations
      end

    end
  end
end

