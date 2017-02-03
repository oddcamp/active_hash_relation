describe ActiveHashRelation do
  include Helpers

  context 'sorting' do
    context "one where clause" do
      it "asc" do
        hash = {
          microposts_count: 10,
          sort: {property: :microposts_count, order: :asc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)",
          "ORDER BY users.microposts_count ASC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple where clause" do
          hash = {
            microposts_count: 10,
            sort: {property: :microposts_count, order: :desc}
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count = 10)",
            "ORDER BY users.microposts_count DESC"
          )

          expect(strip(query)).to eq expected_query.to_s
      end
    end

    context "multiple where clauses" do
      it "asc" do
        hash = {
          followers_count: {leq: 20},
          microposts_count: 10,
          sort: {property: :microposts_count, order: :asc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)",
          "AND (users.followers_count <= 20)",
          "ORDER BY users.microposts_count ASC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple where clause" do
        hash = {
        followers_count: {leq: 20},
          microposts_count: 10,
          sort: {property: :microposts_count, order: :desc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)",
          "AND (users.followers_count <= 20)",
          "ORDER BY users.microposts_count DESC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end

    context "multiple sorting properties" do
      it "with single where clause" do
        hash = {
          microposts_count: 10,
          sort: [{
            property: :microposts_count, order: :asc,
          }, {
            property: :followings_count, order: :desc
          }]
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)",
          "ORDER BY users.microposts_count ASC, users.followings_count DESC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end

end
