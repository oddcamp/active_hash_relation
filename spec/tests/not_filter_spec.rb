describe ActiveHashRelation do
  include Helpers

  context 'NOT filter' do
    it "one NOT clause" do
      hash = {not: {name: 'Filippos'}}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE NOT users.name = 'Filippos'"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    it "multiple NOT clauses" do
      hash = {not: {name: 'Filippos', email: 'vasilakisfil@gmail.com'}}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users WHERE",
        "NOT (users.name = 'Filippos'))",
        "AND",
        "NOT (users.email = 'vasilakisfil@gmail.com'))"
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    if ActiveRecord::VERSION::MAJOR >= 5
      it "NOT clause inside OR clause" do
        hash = {or: [{not: {name: 'Filippos', token: '123'}}, {not: {name: 'Vasilis'}}]}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE",
          "(",
            "NOT (users.name = 'Filippos') AND NOT (users.token = '123')",
            "OR",
            "NOT (users.name = 'Vasilis')",
          ")"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end

    it "complex NOT clause" do
      hash = {not: {name: 'Filippos', email: {ends_with: '@gmail.com'}}}

      query = HelperClass.new.apply_filters(User.all, hash).to_sql
      expected_query = q(
        "SELECT users.* FROM users",
        "WHERE",
        "NOT (users.name = 'Filippos')",
        "AND",
        "NOT (users.email LIKE '%@gmail.com')",
      )

      expect(strip(query)).to eq expected_query.to_s
    end

    context "on NULL" do
      it "NOT clause on null" do
        hash = {not: {name: {null: true}}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE NOT (users.name IS NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "NOT clause on not null" do
        hash = {not: {name: {null: false}}}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users WHERE NOT (users.name IS NOT NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end

    it "NOT clause on associations" do
        hash = {microposts: {not: {content: 'Sveavägen 4', id: 1}}}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN microposts ON microposts.user_id = users.id",
          "WHERE",
          "NOT (microposts.id = 1)",
          "AND",
          "NOT (microposts.content = 'Sveavägen 4')"
        )

        expect(strip(query)).to eq expected_query.to_s
    end

  end
end
