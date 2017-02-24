describe ActiveHashRelation do
  include Helpers

  context 'aggregations' do
    context 'avg' do
      before do
        FactoryGirl.create_list(:micropost, 10)
      end

      it "one aggregation" do
        hash = { aggregate: {likes: {avg: true} } }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            avg: Micropost.pluck(:likes).avg
          }
        })
        expect(aggregations).to eq expected_aggregations
      end
      it "multiple aggregations" do
        hash = {
          aggregate: {
            likes: {avg: true}, reposts: {avg: true}, created_at: {avg: true}
          }
        }

        aggregations = HelperClass.new.aggregations(Micropost.all, hash)
        expected_aggregations = HashWithIndifferentAccess.new({
          likes: {
            avg: Micropost.pluck(:likes).avg
          },
          reposts: {
            avg: Micropost.pluck(:reposts).avg
          },
          created_at: {}
        })
        expect(aggregations).to eq expected_aggregations
      end

    end
  end
end


