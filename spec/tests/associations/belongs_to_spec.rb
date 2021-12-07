describe ActiveHashRelation do
  include Helpers

  context 'associations' do
    context 'belongs_to' do
      it "one where clause" do
        hash = {user: {name: 'Filippos' }}

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE (users.name = 'Filippos')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
      it "multiple where clause" do
        hash = {user: {name: 'Filippos', verified: true }}

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE (users.name = 'Filippos')",
          "AND users.verified = TRUE"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple queries" do
        date = DateTime.now.utc.to_s
        hash = {
          user: {
            name: {starts_with: 'filippos', with_ilike: true},
            created_at: {leq: date}
          }
        }

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE (users.name ILIKE 'filippos%')",
          "AND (users.created_at <= '#{date}')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "scope" do
        hash = {user: {scopes: {unverified: true} }}

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE users.verified = FALSE"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "null" do
        hash = {user: {name: {null: true} }}

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE (users.name IS NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "sorting" do
        hash = {user: {name: 'Filippos', sort: {property: :created_at} }}

        query = HelperClass.new.apply_filters(Micropost.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts",
          "INNER JOIN users ON users.id = microposts.user_id",
          "WHERE (users.name = 'Filippos')",
          "ORDER BY users.created_at DESC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end



