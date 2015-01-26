# ActiveJsonRelation

## Introduction
Simple gem that allows you to manipulate ActiveRecord::Relation using JSON. For instance:
```ruby
apply_filters(resource, {name: 'RPK', id: [1,2,3,4,5,6,7,8,9], start_date: {leq: "2014-10-19"}, act_status: "ongoing"})
```
filter a resource based on it's associations:
```ruby
apply_filters(resource, {updated_at: { geq: "2014-11-2 14:25:04"}, unit: {id: 9})
```
or even filter a resource based on it's associations' associations:
```ruby
apply_filters(resource, {updated_at: { geq: "2014-11-2 14:25:04"}, unit: {id: 9, areas: {id: 22} }})
```
and the list could go on.. Basically your whole db is exposed there. It's perfect for filtering a collection of resources on APIs.

## Installation

Add this line to your application's Gemfile:

    gem 'active_json_relation'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_json_relation
## How to use
The gem exposes only one method: `apply_filters(resource, json_params, include_associations: true, model: nil)`. `resource` is expected to be an ActiveRecord::Relation.
That way, you can add your custom filters before passing the `Relation` to `ActiveJsonRelation`.

In order to use it you have to include ActiveJsonRelation module in your class. For instance in a Rails API controller you would do:

```ruby
class Api::V1::ResourceController < Api::V1::BaseController
  include ActiveJsonRelation

  def index
    resources = apply_filters(Resource.all, params)

    authorized_resources = policy_scope(resource)

    render json: resources, each_serializer: Api::V1::ResourceSerializer
  end
end
```

## The API
### Columns
For each param, `apply_filters` method will search in the model's (derived from the first param, or explicitly defined as the last param) all the record's column names and associations. (filtering based on scopes are not working at the moment but will be supported soon). For each column, if there is such a param, it will apply the filter based on the column type. The following column types are supported:

#### Primary
You can apply a filter in a primary key using an array like:
* `{primary_key: [1,3,4,5,6,7]}`

#### Integer, Float, Decimal, Date, Time or Datetime/Timestamp
You can apply an equality filter:
* `{example_column: 500}`
or using a hash as a value you get more options:
* `{example_column: {le: 500}}`
* `{example_column: {leq: 500}}`
* `{example_column: {ge: 500}}`
* `{example_column: {geq: 500}}`

Of course you can provide a compination of those like:
* `{example_column: {geq: 500, le: 1000}}`

The same api is for Date, Time or Datetime/Timestamp.

#### Boolean
The boolean value is converted from string using ActiveRecord's `TRUE_VALUES` through `value_to_boolean` method.. So for a value to be true must be one of the following: `[true, 1, '1', 't', 'T', 'true', 'TRUE']`. Anything else is false. 
* `{example_column: true}`
* `{example_column: 0}`

#### String or Text
You can apply an incensitive matching filter (currently working only for Postgres):
* `{example_column: test}`

The above filter will search all records that include `test` in the `example_column` field. A better would be nice here, for instance, setting the search sensitive or insensitive, start or end with a string etch


### Associations
If the association is a `belongs_to` or `has_one`, then the json attribute name must be in singular. If the association is `has_many` the attribute must be in plural reflecting the association type. When you have in your json filters for an association, the sub-json is passed in the association's model. For instance, let's say a user has many microposts and the following filter is applied (could be through an HTTP GET request on controller's index method):
* `{email: test@user.com, microposts: {created_at { leq: 12-9-2014} }`

Internally, ActiveJsonRelation, extracts `{created_at { leq: 12-9-2014} }` and runs it on Micropost model. So the final query will look like:

```ruby
micropost_filter = Micropost.all.where("CREATED_AT =< ?", '12-9-2014'.to_datetime)
User.where(email: 'test@user.com').joins(:microposts).merge(micropost_filter)
```

### Scopes
Not supported yet but it will be in the future. Unfortunately, Rails doesn't hold the scopes internally, so we will either have to monkeypatch scope class method or add support for adding custom model class methods in the filters.

### Whitelisting
It would be nice to add support for whitelisting associations/column names from the filtering. Probably you won't want to expose the whole DB as it is. Currently, you can only disable associations passing false to `include_associations` param.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_json_relation/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
