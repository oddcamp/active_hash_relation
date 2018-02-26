describe ActiveHashRelation do
  include Helpers

  context 'numbers' do
    it "one where clause" do
      hash = {microposts_count: 10}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.microposts_count = 10)"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple where clause" do
      hash = {microposts_count: 3, followers_count: 5}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE (users.microposts_count = 3)",
        "AND (users.followers_count = 5)"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple values" do
      hash = {microposts_count: [3,4,5]}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE (users.microposts_count IN (3, 4, 5))",
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    context "queries" do
      it 'eq' do
        hash = {microposts_count: {eq: 10}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.microposts_count = 10)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'le' do
        hash = {microposts_count: {le: 10}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.microposts_count < 10)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'leq' do
        hash = {microposts_count: {leq: 10}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.microposts_count <= 10)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'ge' do
        hash = {microposts_count: {ge: 10}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.microposts_count > 10)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'geq' do
        hash = {microposts_count: {geq: 10}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.microposts_count >= 10)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      context 'combined' do
        it 'with a single column' do
          hash = {microposts_count: {geq: 10, le: 20}}

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count < 20)",
            "AND (users.microposts_count >= 10)"
          )

          expect(strip(query)).to eq expected_query.to_s
        end

        it 'with multiple columns' do
          hash = {
            microposts_count: {geq: 10, le: 20},
            followers_count: {leq: 50, ge: 0}
          }

          query = HelperClass.new.apply_filters(User.all, hash).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "WHERE (users.microposts_count < 20)",
            "AND (users.microposts_count >= 10)",
            "AND (users.followers_count <= 50)",
            "AND (users.followers_count > 0)"
          )

          expect(strip(query)).to eq expected_query.to_s
        end
      end

      it 'rails enum' do
        hash = {status: 0}

        query = HelperClass.new.apply_filters(Micropost.all, hash).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts WHERE (microposts.status = 0)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'rails string enum' do
        hash = {status: 'published'}

        query = HelperClass.new.apply_filters(Micropost.all, hash).to_sql
        expected_query = q(
          "SELECT microposts.* FROM microposts WHERE (microposts.status = #{Micropost.statuses[:published]})"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end
