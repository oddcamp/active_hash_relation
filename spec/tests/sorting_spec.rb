describe ActiveHashRelation do
  include Helpers

  context 'sorting' do

    context "one where clause" do
      it "asc" do
        hash = {
          microposts_count: 10,
          sort: {microposts_count: :asc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)",
          "ORDER BY users.microposts_count ASC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "desc" do
          hash = {
            microposts_count: 10,
            sort: {microposts_count: :desc}
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
          sort: {microposts_count: :asc}
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

      it "desc" do
        hash = {
        followers_count: {leq: 20},
          microposts_count: 10,
          sort: {microposts_count: :desc}
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
      context "as a hashe" do
        it "with single where clause" do
          hash = {
            microposts_count: 10,
            sort: {
              microposts_count: :asc,
              followings_count: :desc
            }
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count = 10)",
            "ORDER BY users.microposts_count ASC, users.followings_count DESC"
          )

          expect(strip(query)).to eq expected_query.to_s
        end

        it "when the sorting column does not exist" do
          hash = {
            microposts_count: 10,
            sort: {
              i_do_not_exist: :asc,
              followings_count: :desc
            }
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count = 10)",
            "ORDER BY users.followings_count DESC"
          )

          expect(strip(query)).to eq expected_query.to_s
        end
      end

      context "as an array of hashes (not recommended)" do
        it "with single where clause" do
          hash = {
            microposts_count: 10,
            sort: [{
              microposts_count: :asc,
            }, {
              followings_count: :desc
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

        it "when the sorting column does not exist" do
          hash = {
            microposts_count: 10,
            sort: [{
              i_do_not_exist: :asc,
            }, {
              followings_count: :desc
            }]
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count = 10)",
            "ORDER BY users.followings_count DESC"
          )

          expect(strip(query)).to eq expected_query.to_s
        end
      end

      it "when the sorting column does not exist" do
        hash = {
          microposts_count: 10,
          sort: {i_do_not_exist: :asc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)"
        )

        expect(strip(query)).to eq expected_query.to_s

      end
    end

    context "deprecated API" do
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

        it "desc" do
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

        it "desc" do
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

      it "when the sorting column does not exist" do
          hash = {
            microposts_count: 10,
            sort: [{
              property: :i_do_not_exist, order: :asc,
            }, {
              property: :followings_count, order: :desc
            }]
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count = 10)",
            "ORDER BY users.followings_count DESC"
          )

          expect(strip(query)).to eq expected_query.to_s
        end
      end

      it "when the sorting column does not exist" do
        hash = {
          microposts_count: 10,
          sort: {property: :i_do_not_exist, order: :asc}
        }

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE (users.microposts_count = 10)"
        )

        expect(strip(query)).to eq expected_query.to_s

      end
    end
  end
end
