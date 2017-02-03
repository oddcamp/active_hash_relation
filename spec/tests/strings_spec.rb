describe ActiveHashRelation do
  include Helpers

  context 'strings' do
    it "one where clause" do
      hash = {name: 'Filippos'}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.name = 'Filippos')"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple where clause" do
      hash = {name: 'Filippos', token: '123'}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE (users.name = 'Filippos')",
        "AND (users.token = '123')"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple values" do
      hash = {name: ['Filippos', 'Vasilakis']}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE (users.name IN ('Filippos', 'Vasilakis'))"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    context "queries" do
      it 'eq' do
        hash = {name: {eq: 'Filippos'}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.name = 'Filippos')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'starts_with' do
        hash = {name: {starts_with: 'Filippos'}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.name LIKE 'Filippos%')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'ends_with' do
        hash = {name: {ends_with: 'Filippos'}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.name LIKE '%Filippos')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it 'like' do
        hash = {name: {like: 'Filippos'}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE (users.name LIKE '%Filippos%')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end
