describe ActiveHashRelation do
  include Helpers

  context 'NULL' do
    context "one where clause" do
      it "is null" do
        hash = {admin: {null: true}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.admin IS NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "is not null" do
        hash = {admin: {null: false}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.admin IS NOT NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end

    it "multi where clauses" do
      hash = {admin: {null: true}, verified: {null: false}}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE (users.admin IS NULL)",
        "AND (users.verified IS NOT NULL)"
      )

      expect(strip(query)).to eq expected_query.to_s
    end
  end
end
