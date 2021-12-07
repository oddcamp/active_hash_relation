describe ActiveHashRelation do
  include Helpers

  context 'associations' do
    context 'has_many' do
      it "one where clause" do
        hash = {microposts: {content: 'Sveavägen 4' }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (microposts.content = 'Sveavägen 4')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple where clause" do
        hash = {microposts: {content: 'Sveavägen 4', created_at: '2017-01-15 16:11:06 UTC' }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (microposts.content = 'Sveavägen 4')",
          "AND microposts.created_at = '2017-01-15 16:11:06'"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple queries" do
        hash = {microposts: {content: {ends_with: '4'}, created_at: {leq: '2017-01-15 16:11:06 UTC'} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (microposts.content LIKE '%4')",
          "AND (microposts.created_at <= '2017-01-15 16:11:06')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "scope" do
        date = DateTime.now.to_date.to_s
        hash = {microposts: {scopes: {created_on: [date] }}}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (date(microposts.created_at) = '#{date}')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "null" do
        hash = {microposts: {content: {null: true} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (microposts.content IS NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "sorting" do
        hash = {microposts: {content: 'Sveavägen 4', sort: {property: :created_at} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE (microposts.content = 'Sveavägen 4')",
          "ORDER BY microposts.created_at DESC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end


