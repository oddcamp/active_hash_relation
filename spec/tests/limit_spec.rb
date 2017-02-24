describe ActiveHashRelation do
  include Helpers

  context 'limit' do
    it "one where clause" do
      hash = {microposts_count: 10, limit: 10}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.microposts_count = 10) LIMIT 10"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple where clause" do
      hash = {microposts_count: 3, followers_count: 5, limit: 10}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE (users.microposts_count = 3)",
        "AND (users.followers_count = 5)",
        "LIMIT 10"
      )

      expect(strip(query)).to eq expected_query.to_s
    end
  end
end
