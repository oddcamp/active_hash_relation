describe ActiveHashRelation do
  include Helpers

  context 'scopes' do
    context 'without parameters' do
      it "one scope clause" do
        hash = {scopes: {unsocial: true}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE users.followings_count = 0",
          "AND users.followers_count = 0"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple scope clauses" do
        hash = {scopes: {unsocial: true, unverified: true}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE users.verified = FALSE",
          "AND users.followings_count = 0",
          "AND users.followers_count = 0"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end

    context 'with parameters' do
      it "one scope clause" do
        hash = {scopes: {created_on: [Date.parse("12-12-1988")]}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (date(created_at) = '1988-12-12')",
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end
