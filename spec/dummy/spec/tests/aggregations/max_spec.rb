require 'rails_helper'

describe ActiveHashRelation do
  include Helpers

  context 'aggregations' do
    context 'max' do
      before do
        FactoryGirl.create_list(:micropost, 10)
      end

      it "one aggregation" do
        hash = { aggregate: {likes: {max: true} } }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            max: Micropost.pluck(:likes).max
          }
        })
        expect(aggregations).to eq expected_aggregations
      end
      it "multiple aggregations" do
        hash = {
          aggregate: {
            likes: {max: true}, reposts: {max: true}, created_at: {max: true}
          }
        }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            max: Micropost.pluck(:likes).max,
          },
          reposts: {
            max: Micropost.pluck(:reposts).max,
          },
          created_at: {
            max: Micropost.pluck(:created_at).max.to_time
          }
        })
        expect(aggregations).to eq expected_aggregations
      end

    end
  end
end
