describe ActiveHashRelation do
  include Helpers

  context 'aggregations' do
    context 'sum' do
      before do
        FactoryGirl.create_list(:micropost, 10)
      end

      it "one aggregation" do
        hash = { aggregate: {likes: {sum: true} } }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            sum: Micropost.pluck(:likes).sum
          }
        })
        expect(aggregations).to eq expected_aggregations
      end
      it "multiple aggregations" do
        hash = {
          aggregate: {
            likes: {sum: true}, reposts: {sum: true}, created_at: {sum: true}
          }
        }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            sum: Micropost.pluck(:likes).sum
          },
          reposts: {
            sum: Micropost.pluck(:reposts).sum
          },
          created_at: {}
        })
        expect(aggregations).to eq expected_aggregations
      end

    end
  end
end
