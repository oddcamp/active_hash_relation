require 'rails_helper'

describe ActiveHashRelation do
  include Helpers

  context 'associations' do
    context 'has_one' do
      it "one where clause" do
        hash = {address: {street: 'Sveavägen 4' }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE (addresses.street = 'Sveavägen 4')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple where clause" do
        hash = {address: {street: 'Sveavägen 4', country: 'SE' }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE (addresses.street = 'Sveavägen 4')",
          "AND (addresses.country = 'SE')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "multiple queries" do
        hash = {address: {street: {like: 'sveav', with_ilike: true}, city: {starts_with: 'New'} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE (addresses.street ILIKE '%sveav%')",
          "AND (addresses.city LIKE 'New%')"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "scope" do
        hash = {address: {scopes: {in_sweden: true} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE addresses.country = 'SE'"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "null" do
        hash = {address: {street: {null: false} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE (addresses.street IS NOT NULL)"
        )

        expect(strip(query)).to eq expected_query.to_s
      end

      it "sorting" do
        hash = {address: {street: {like: 'svea'}, sort: {property: :street, order: :asc} }}

        query = HelperClass.new.apply_filters(User.all, hash, include_associations: true).to_sql
        expected_query = q(
          "SELECT users.* FROM users",
          "INNER JOIN addresses ON addresses.user_id = users.id",
          "WHERE (addresses.street LIKE '%svea%')",
          "ORDER BY addresses.street ASC"
        )

        expect(strip(query)).to eq expected_query.to_s
      end
    end
  end
end

