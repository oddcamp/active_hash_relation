describe ActiveHashRelation do
  include Helpers

  context 'booleans' do
    it "one boolean where clause" do
      hash = {admin: false}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE users.admin = FALSE"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multi boolean where clauses" do
      hash = {admin: false, verified: true}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE users.admin = FALSE AND users.verified = TRUE"
      )

      expect(strip(query)).to eq expected_query.to_s
    end
  end
end
