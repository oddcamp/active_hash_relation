describe ActiveHashRelation do
  include Helpers

  if ActiveRecord::VERSION::MAJOR < 5
    context 'OR filter' do
      it "one OR clause" do
        logger = double('logger')
        allow(logger).to receive(:warn)
        allow(Rails).to receive(:logger).and_return(logger)

        hash = {or: [{name: 'Filippos'}, {name: 'Vasilis'}]}

        HelperClass.new.apply_filters(User.all, hash).to_sql
        expect(logger).to have_received(:warn)
      end
    end

  else
    context 'OR filter' do
      it "one OR clause" do
        hash = {or: [{name: 'Filippos'}, {name: 'Vasilis'}]}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE ((users.name = 'Filippos') OR (users.name = 'Vasilis'))"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple OR clauses" do
        hash = {or: [{or: [{name: 'Filippos'}, {name: 'Vasilis'}]}, {or: [{id: 1}, {id: 2}]}]}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE",
          "(",
          "((users.name = 'Filippos') OR (users.name = 'Vasilis'))",
          "OR",
          "((users.id = 1) OR (users.id = 2))",
          ")"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "one complex OR clause" do
        hash = {or: [{name: 'Filippos', token: '123'}, {name: 'Vasilis'}]}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE",
          "(",
            "(users.name = 'Filippos') AND (users.token = '123')",
            "OR",
            "(users.name = 'Vasilis')",
          ")"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "nested OR clause" do
        hash = {or: [{or: [{name: 'Filippos'}, {token: '123'}]}, {name: 'Vasilis'}]}

        query = HelperClass.new.apply_filters(User.all, hash).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "WHERE",
          "(",
            "((users.name = 'Filippos') OR (users.token = '123'))",
            "OR",
            "(users.name = 'Vasilis')",
          ")"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "OR clause on associations" do
          hash = {microposts: {or: [{content: 'Sveavägen 4'}, {id: 1}]}}

          query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
          expected_query = q(
            "SELECT users.* FROM users",
            "INNER JOIN microposts ON microposts.user_id = users.id",
            "WHERE ((microposts.content = 'Sveavägen 4') OR (microposts.id = 1))"
          )

          expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end

