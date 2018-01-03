# ActiveHashRelation
[ ![Codeship Status for kollegorna/active_hash_relation](https://app.codeship.com/projects/02f08850-cc66-0134-028f-5ad72e690a75/status?branch=master)](https://app.codeship.com/projects/200194)

ActiveHashRelation is a complete substitute of ActiveRecord::Relation that allows you to run ActiveRecord queries using only regular Hash using a very powerful yet simple API. It was initially built to allow front-end teams to specify from the API exactly what they need withoug bugging the backend developers, eventually emerged into its own little gem.

## Introduction
Simple gem that allows you to manipulate ActiveRecord::Relation using JSON. For instance:
```ruby
apply_filters(User.all, {name: 'filippos', created_at: {leq: "2016-10-19"}, role: 'regular', email: {like: 'vasilakis'}})
```
filter a resource based on it's associations using a NOT filter:
```ruby
apply_filters(Microposts.all, {updated_at: { geq: "2014-11-2 14:25:04"}, user: {not: {email: vasilakisfil@gmail.com}})
```
or even filter a resource based on it's associations' associations using an OR filter:
```ruby
apply_filters(Comments.all, {updated_at: { geq: "2014-11-2 14:25:04"}, user: {id: 9, units: {or: [{id: 22}, {id: 21}]} }})
```
and the list could go on.. Basically you can run anything ActiveRecord supports, except from groupping. It's perfect for filtering a collection of resources on APIs.

It should be noted that `apply_filters` calls `ActiveHashRelation::FilterApplier` class
underneath with the same params.

You can also do [__aggregation queries__](#aggregation-queries), like `sum`, `avg`, `min` and `max` on any column.

_\*A user could retrieve resources based
on unknown attributes (attributes not returned from the API) by brute forcing
which might or might not be a security issue. If you don't like that check you can specify from the `params` exactly what is allowed and what is not allowed. For more information check: [whitelisting](#whitelisting)._


## Installation

Add this line to your application's Gemfile:

    gem 'active_hash_relation', '~> 1.4.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_hash_relation

## How to use
The gem exposes only one method: `apply_filters(resource, hash_params, include_associations: true, model: nil)`.
`resource` is expected to be an ActiveRecord::Relation.
That way, you can add your custom filters before passing the `Relation` to `ActiveHashRelation`.

In order to use it you have to include ActiveHashRelation module in your class. For instance in a Rails API controller you would do:

```ruby
class Api::V1::ResourceController < Api::V1::BaseController
  include ActiveHashRelation

  def index
    resources = apply_filters(Resource.all, params)

    authorized_resources = policy_scope(resource)

    render json: resources, each_serializer: Api::V1::ResourceSerializer
  end
end
```

If you **need to enable filtering on scopes**, you need to specify that explicitly from the initializer. Please run:
`bundle exec rails g active_hash_relation:initialize` which will create an initializer with the following content:

```ruby
ActiveHashRelation.configure do |config|
  #override default scope when accessing associations
  config.use_unscoped = true
  #set true to be able to filter scopes (with params)
  #please note that unfortunately (:/) rails does not provide any way
  #to iterate through scopes so it uses a monkey patch.
  #The monkey patch is as gentle as it can be by aliasing the method, adds some
  #sugar and calls it,
  #You need to run `initialize!` to actually include the required files
  config.filter_active_record_scopes = true
end

  #requires monkeyparched scopes, optional if you don't enable them
  ActiveHashRelation.initialize!
```
If you are not using Rails, just add the code above in your equivelant initialize block.

## The API
### Columns
For each param, `apply_filters` method will search in the model's (derived from the
first param, or explicitly defined as the last param) all the record's column names
and associations. (filtering based on scopes are not working at the moment but
will be supported soon). For each column, if there is such a param, it will
apply the filter based on the column type. The following column types are supported:


#### Integer, Float, Decimal, Date, Time or Datetime/Timestamp
You can apply an equality filter:

* `{example_column: 500}`

or using an array (`ActiveRecord` translates that internally to an `IN` query)
* `{example_column: [500, 40]}`

or using a hash as a value you get more options:
* `{example_column: {le: 500}}`
* `{example_column: {leq: 500}}`
* `{example_column: {ge: 500}}`
* `{example_column: {geq: 500}}`

Of course you can provide a compination of those like:
* `{example_column: {geq: 500, le: 1000}}`

The same api is for a Float, Decimal, Date, Time or Datetime/Timestamp.

#### Boolean
The boolean value is converted from string using ActiveRecord's `TRUE_VALUES` through `value_to_boolean` method.. So for a value to be true must be one of the following: `[true, 1, '1', 't', 'T', 'true', 'TRUE']`. Anything else is false. 
* `{example_column: true}`
* `{example_column: 0}`

#### String or Text
You can apply an incensitive matching filter (currently working only for Postgres):
* `{example_column: 'test'}` `#runs EXAMPLE_COLUMN = 'test'`
* `{example_column: ['test', 'another test']}` `#runs EXAMPLE_COLUMN = 'test' OR EXAMPLE_COLUMN = 'another test'`

or using a hash as a value you get more options:
* `{example_column: {eq: 'exact value'}}` `#runs: EXAMPLE_COLUMN = 'test'`
* `{example_column: {starts_with: 'exac'}}` `#runs: EXAMPLE_COLUMN LIKE 'test%'`
* `{example_column: {ends_with: 'alue'}}` `#runs: EXAMPLE_COLUMN LIKE '%test'`
* `{example_column: {like: 'ct_va'}}` `#runs: EXAMPLE_COLUMN LIKE '%test%'`

If you want to filter using `ILIKE` you can pass an `with_ilike` param:

* `{example_column: {like: 'ct_va', with_ilike: true}}` `#runs: EXAMPLE_COLUMN ILIKE '%test%'`
* `{example_column: {like: 'ct_va', with_ilike: true}}` `#runs: EXAMPLE_COLUMN ILIKE '%test%'`


**Please note that ILIKE and especially LIKE are quite slow if you have millions of records in the db even with an index.**

### Limit
A limit param defines the number of returned resources. For instance:
* `{limit: 10}`

However I would strongly advice you to use a pagination gem like Kaminari, and use `page` and `per_page` params.


### Sorting
You can apply sorting using the property as the key of the hash and order as the value. For instance:
* `{sort: {created_at: desc}}`

You can also order by multiple attributes:
* `{sort: {created_at: desc, microposts_count: :asc}}`

If there is no column named after the property value, sorting is skipped.

#### Deprecated API (will be removed in version 2.0)
You can apply sorting using the `property` and `order` attributes. For instance:
* `{sort: {property: :created_at, order: :desc}}`

You can also order by multiple attributes:
* `{sort: [{property: :created_at, order: :desc}, {property: :created_at, order: :desc}]}`

If there is no column named after the property value, sorting is skipped.


### Associations
If the association is a `belongs_to` or `has_one`, then the hash key name must be in singular. If the association is `has_many` the attribute must be in plural reflecting the association type. When you have, in your hash, filters for an association, the sub-hash is passed in the association's model. For instance, let's say a user has many microposts and the following filter is applied (could be through an HTTP GET request on controller's index method):
* `{email: test@user.com, microposts: {created_at { leq: 12-9-2014} }`

Internally, ActiveHashRelation, extracts `{created_at { leq: 12-9-2014} }` and runs it on Micropost model. So the final query will look like:

```ruby
micropost_filter = Micropost.all.where("CREATED_AT =< ?", '12-9-2014'.to_datetime)
User.where(email: 'test@user.com').joins(:microposts).merge(micropost_filter)
```

### NULL Filter
You can apply null filter for generate query like this `"users.name IS NULL"` or `"users.name IS NOT NULL"` with this following code:
`{ name: { null: true } }` for is null filter and `{ name: { null: false } }` for not null filter.

this can be used also for relations tables, so you can write like this `{ books: {title: {null: false }} }`


### OR Filter
You can apply an SQL `OR` (for ActiveRecord 5+) using the following syntax:
`{or: [{name: 'Filippos'}, {name: 'Vasilis'}]}`

It will generate: `WHERE ((users.name = 'Filippos') OR (users.name = 'Vasilis'))`

You can apply an `OR` on associations as well or even nested ones, there isn't much limitation on that.
I suggest you though to take a look on the [tests](spec/tests/or_filter_spec.rb), cause the syntax gets a bit complex after a while ;)


### NOT Filter
You can apply an SQL `NOT` (for ActiveRecord 4+) using the following syntax:
`{not: {name: 'Filippos', email: {ends_with: '@gmail.com'}}}`

It will generate: `WHERE (NOT (users.name = 'Filippos')) AND (NOT (users.email LIKE '%@gmail.com'))`

You can apply an `NOT` on associations as well or even nested ones, there isn't much limitation on that.
I suggest you to also take a look on the [tests](spec/tests/not_filter_spec.rb).

Also I should note that you need to add specific (partial) queries if you don't want
to have performance issues on tables with millions of rows.


### Scopes
**Filtering on scopes is not enabled by default. You need to add the initializer mentioned in the beginning of the [How to use](#how-to-use) section.**.

Scopes are supported via a tiny monkeypatch in the ActiveRecord's scope class method which holds the name of each scope.
The monkey patch is as gentle as it can be: it aliases the method, adds some sugar and executes it.

Scopes with arguments are also supported but not tested much. Probably they will work fine unless your arguments expect
complex objects.

If you want to filter based on a scope in a model, the scope names should go under `scopes` sub-hash. For instance the following:
* `{ scopes: { planned: true } }`

will run the `.planned` scope on the resource.

* `{scopes: {created_between: [1988, 2018]}}`

will run the `.created_on(1988, 2018)` scope on the resource.

### Unscoped assotiations
If you have a default scope in your models and you have a good reason to keep that, `active_hash_relation` provides an option to override it when filtering associations:

```ruby
#config/initializers/active_hash_relation.rb
ActiveHashRelation.configure do |config|
  config.use_unscoped = true
end
```

You still have to provide the main model `active_hash_relation` runs as unscoped though.
```ruby
apply_filters(Video.unscoped.all, {limit: 30, user: {country_code: 'SE'}})
#"SELECT  \"videos\".* FROM \"videos\" INNER JOIN \"users\" ON \"users\".\"id\" = \"videos\".\"user_id\" WHERE (users.country_code ILIKE '%GR%') LIMIT 30"
```

### Whitelisting
If you don't want to allow a column/association/scope just remove it from the params hash.

#### Filter Classes
Sometimes, especially on larger projects, you have specific classes that handle
the input params outside the controllers. You can configure the gem to look for
those classes and call `apply_filters` which will apply the necessary filters when
iterating over associations.

In an initializer:
```ruby
#config/initializers/active_hash_relation.rb
ActiveHashRelation.configure do |config|
  config.has_filter_classes = true
  config.filter_class_prefix = 'Api::V1::'
  config.filter_class_suffix = 'Filter'
end
```
With the above settings, when the association name is `resource`,
`Api::V1::ResourceFilter.new(resource, params[resource]).apply_filters` will be
called to apply the filters in resource association.

## Aggregation Queries
Sometimes we need to ask the database queries that act on the collection but don't want back an array of elements but a value instead! Now you can do that on an ActiveRecord::Relation by simply calling the aggregations method inside the controller:

```ruby
aggregations(resource, {
  aggregate: {
    integer_column: { avg: true, max: true, min: true, sum: true },
    float_column: {avg: true, max: true, min: true },
    datetime_column: { max: true, min: true }
  }
})
```

and you will get a hash (HashWithIndifferentAccess) back that holds all your aggregations like:
```ruby
{"float_column"=>{"avg"=>25.5, "max"=>50, "min"=>1},
 "integer_column"=>{"avg"=>4.38, "sum"=>219, "max"=>9, "min"=>0},
 "datetime_at"=>{"max"=>2015-06-11 20:59:14 UTC, "min"=>2015-06-11 20:59:12 UTC}}
```

These attributes usually go to the "meta" section of your serializer. In that way it's easy to parse them in the front-end (for ember check [here](http://guides.emberjs.com/v1.10.0/models/handling-metadata/)). Please note that you should apply the aggregations __after__ you apply the filters (if there any) but __before__ you apply pagination!



## Contributing

1. Fork it ( https://github.com/[my-github-username]/active_hash_relation/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
