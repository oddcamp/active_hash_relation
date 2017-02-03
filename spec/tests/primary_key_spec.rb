describe ActiveHashRelation do
  include Helpers

  context 'primary_key' do
    it "one key" do
      hash = {id: 1}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.id = 1)"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple keys" do
      hash = {id: [1,2,3,4]}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.id IN (1, 2, 3, 4))"
      )

      expect(strip(query)).to eq expected_query.to_s
    end
  end
end


