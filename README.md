# Trax Model
A higher level, even more opinionated active record model. Some of the features are postgres specific, but library itself should work with anything. Just include ::Trax::Model module and you're off to the races. The library currently contains two major components, a declarative, explicit attribute definitions dsl, and mixins. It also has additional STI support, but don't use the MTI stuff that's getting ripped out.

## Attributes

An declarative, more explicit attributes dsl for your models. Biggest feature at the moment is
support for struct (json), fields, as well as enum (integer) fields.
Also supports faux array/set fields in postgres (using jsonb instead of the text array type)


**Assume this structure for all of the following examples**

``` ruby
class Post
  define_attributes do
    string :title

    enum :category, :default => :tutorials do
      define :tutorials, 1
      define :rants, 2
      define :news, 3
      define :politics, 4
    end

    set :related_categories
    set :upvoters
    set :downvoters

    #pretend we want to keep running record of each time an ip views post
    #regardless of whether it was unique
    array :ip_addresses_who_viewed

    struct :custom_fields do
      enum :subtype do
        define :video, 1
        define :text, 2
        define :audio, 3
      end
    end
  end
end

# Our migration for the example above would like this this:

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, do |t|
      t.string :title
      t.integer :category
      #NOTE:
      #once again, we are using jsonb instead of postgres array type
      #as the storage type for array/set columns. In my experience,
      #array types in postgres are difficult to work with, jsonb
      #is much more matured and easier to work with in general. I don't
      #have benchmarks but I would imagine performance might even be better
      t.jsonb :related_categories
      t.jsonb :upvoters
      t.jsonb :downvoters
      t.jsonb :custom_fields
      t.timestamps null: false
    end
  end
end

#fake records
::Post.create(
  :id => 1,
  :title => "Trax Model, new ruby library",
  :category => 1,
  :upvoters => ["steve"],
  :downvoters => ["cindy"],
  :related_categories => [1, 3]
)

::Post.create(
  :id => 2,
  :title => "Giant Douche and Turd Sandwich battle for the presidency",
  :category => 3,
  :upvoters => ["kyle", "steve"],
  :downvoters => [],
  :related_categories => [2, 4]
)
```

**Searching Enum Fields**

``` ruby
#All of the following are synonymous, eq behaves like arel.in and accepts multiple values
Post.fields[:category].eq(:tutorials, :rants)
#returns post #1
Post.fields[:category].eq("tutorials", "rants")
#returns post #1
Post.fields[:category].eq(1, 2)
#returns post #1
```

### String Type ###

``` ruby
#All of the following are synonymous
Post.fields[:title].eq(:tutorials, :rants)
Post.fields[:category].eq("tutorials", "rants")
Post.fields[:category].eq(1, 2)
```

### Struct Field (json/jsonb) ###

Finally, JSON fields that are usable. Usable as in, if you wanted to use a json field
for anything before, you probably soon after trying to use it, ran into at least one of the following problems:

1. Cant validate it's structure. You almost always want to define the structure of the thing you are allowing into your database. Otherwise its useless
2. Cant validate the components within it's structure. (even more difficult)
3. Setting from user input/how the database casts it is messy to implement and prone to error

So you realize, hey what a waste of time, Ill just create a new model because thats by far a better solution than doing all the above. However,
there are many cases where this will end up making your application messier via unnecessary relations.

**The solution**
``` ruby
struct :custom_fields do
  string :title
  boolean :is_published

  enum :subtype do
    define :video, 1
    define :text, 2
    define :audio, 3
  end

  validates :title, :presence => true
end
```

Getting/setting values works via hash, or via method calls, both work the same.

``` ruby
#access should be indifferent so you can handle user input
::Post.new(:custom_fields => { :subtype => :video, :is_published => false })

#or
post = ::Post.first
post.custom_fields.subtype = :audio
post.save
```

Since struct is an actual value object, it has its own validation state. So you could call:
``` ruby
post.custom_fields.valid?
post.custom_field.errors
```

However, validation errors get pushed up to the root object as well, to make it easy to deal with.

``` ruby
Post.by_custom_fields_subtype(:video, :audio)
```

Yes thats right, you can search by the nested enum field via a search scope. It's a pretty dumb search scope (only supports enums ATM, no greater than or less than or anything that requires casting at the moment, and I really encourage structured i.e. enums to use when using struct to search).

**Warning** Use sparingly if you are doing heavy/many searches in json fields. I have no idea what performance impact to expect from lack of actual benchmarking atm and not a ton of information on pg json field search benchmarks in general, but common sense would say that if you are doing alot of searching on a ton of different values within the json data, particularly if the structures are huge, its probably going to be an expensive query.

Basically what Im saying is, if you allow a single json field to have say a 30mb json object in your db, filled with any number of possible keys and values, whenever you search that table (indexing aside), you're going to have a problem since postgres needs to look through all the col/rows in that table, + that giant field to look for matches to your query. We can reason without much knowledge of PG internals, that this is probably going to be slow.

Remember, just because you can do something, doesn't mean you should.

**With that said, giving your json fields structure, will give you better control over what you allow in the field, thereby making the search more usable. You can ensure that only the keys specified are allowed on that json field (much like a database table), and in the case of enums/boolean even limit the possible values of those keys, while providing meaning since it acts like a normal enum field.**

**Requirements to use struct field**
Fairly postgres specific, and intended to be used with the json field type. It may work with other implementations, but
this library is built to be opinionated and not handle every circumstance. -- Also use a jsonb field (pg 9.4 +)
if you want the search scope magic.

##Enum Field (integer) ##

You may be thiking, whats wrong with rails's built in enum? Answer: Everything. Ill detail somewhere else later, for now,
just know that the enum field type wont pollute your model with a million methods like rails enum.
It also supports setting the enum value by the name of the key, or by its integer value.

Syntax:

``` ruby
define_attributes do
  enum :category, :default => :tutorials do
    define :tutorials, 1
    define :rants, 2
    define :news, 3
  end
end
```

Only one scope method will be defined (unlike rails which defines a scope for every value
within your enum, as well as a thousand instance methods. And if you use the same value
in a different enum field on the same model, you're not going to have a good time.

Assuming a subtype enum as above, you will have the following method which accepts
multiple enum args as input.

``` ruby
Post.by_subtype(:video, :text)
=> Post.where(:subtype => [1, 2])
```

## Mixins

Mixins are one of the core features of Trax model. A mixin is like a concern,
(in fact, mixins extend concern, so they have that behavior as well), but
with a more rigid pattern, with configurability built in. You can pass in options
to your mixin, which will allow you to use those options to define methods and what not
based on the options passed to the mixed_in method. Example:

``` ruby
module Slugify
  extend ::Trax::Model::Mixin

  mixed_in do |*field_names|
    field_names.each do |field_name|
      define_slug_method_for_field(field_name)
    end
  end

  def some_instance_method
    puts "Because I extend ActiveSupport::Concern"
    puts "I am included into post instance methods"
  end

  module ClassMethods
    def find_by_slug(field, *args)
      where(:field => args.map(&:paramaterize))
    end

    private
    def define_slug_method_for_field(field_name)
      define_method("#{field_name}=") do |value|
        super(value.paramaterize)
      end
    end
  end
end
```

You would call the mixin via:

``` ruby
class Post
  mixins :slugify => [ :title, :category ]
end
```

or
``` ruby
class Post
  mixin :slugify, :title, :category
end
```

``` ruby
Post.find_by_slug(:title, "Some Title")
Post.find_by_slug(:category, "Some ")
```

The mixins dsl should look familiar to you since it acts much like "validates". However,
unlike validators, there is one registry with one list of keys. So the first paramater of
the mixin call dictate what mixin gets invoked, and if you overwrite a mixin with same name,
it will call the last one defined.

# Packaged Trax Model Mixins

### UniqueId

``` ruby
mixins :unique_id => { :uuid_prefix => "0a" }
```

Supports uuid prefixes, and recommends next uuid prefix based on all uuid prefixes defined
in system -- Makes your uuids more discoverable and allows you to identify the model
itself just by the uuid, or do even cooler stuff programatically

### ITS IMPERATIVE THAT YOU DO NOT CHANGE YOUR UUID PREFIXES AFTER CREATING RECORDS

Sorry for yelling, but the point is, that will throw all the mapping stuff out of whack.
Don't do it. Treat it as a single point of truth for identifying the model in your system.

### UUID Prefixes should be treated like an enum, values are ordered like

[0a, 0b, 0c...], from 0-9a-f, then back down in reverse, i.e.

[a0, a1, a2], the alpha first prefixes are a higher sort order in the list

### Why?

This library is compatible with postgres's uuid, hexidecimal type. This enables
you to use the library to generate uuids on the fly, in your application code,
WITHOUT relying on primary key integer increment, which in case you haven't yet realized,
is the wild west once you are processing enough writes that you start seeing duplicate
primary key errors.

### Can't there still be conflicts?

Yes but the odds are astronomically small. From what I understand, probably you are more
likely to get struck by lightning than see that error. With that said, I am overwriting
the first 2 generated characters of the uuid function with a fixed character string, which
may affect the stats slightly, however Im not even sure if thats in a negative manner,
based on the fact that it splits the likeleyhood of a collision per record type

Usage

``` ruby
class Product < ActiveRecord::Base
  include ::Trax::Model

  mixins :unique_id => {
    :uuid_prefix => "0a"
  }
end
```

``` ruby
Product.new

=> #<Product id: nil, name: nil, category_id: nil, user_id: nil, price: nil, in_stock_quantity: nil, on_order_quantity: nil, active: nil, uuid: "0a97ad3e-1673-41f3-b356-d62dd53629d8", created_at: nil, updated_at: nil>
```

### Or, register prefixes using dsl rather than in each individual class

``` ruby

Trax::Model::UUID.register do
  prefix "1a", Product
  prefix "1b", Category
end
```

### UUID utility methods

``` ruby
product_uuid = Product.first.uuid
=> "0a97ad3e-1673-41f3-b356-d62dd53629d8"

product_uuid.record_type
=> Product
product_uuid.record
```
Will return the product instance, Which opens up quite a few possibilites via the newfound discoverability of your uuids...

## Field Scopes ##
``` ruby
mixins :field_scopes => {
  :by_id => true,
  :by_id_not => { :field => :id, :type => :not },
  :by_name_matches => { :field => :name, :type => :matches }
}
```

Here's a quick protip to writing better rails code. Treat the where method as private at all times. Use scopes to define the fields that can be searched, and keep them composable and chainable. Most search scopes should simply equate to "where field contains any number of these values". It's (generalizing) roughly the same performance hit to search one field for 100 values as it is to search one field for one value provided that value is at the bottom of the table.

Based on those rules, 3 primary scope types right now.

1. where
2. where_not
3. matching (contains | fuzzy)

I like having the by_ affix attached to search scopes in most cases, so if your field contains a by_ it will try and guess the field name based on the fact.

The preceeding example will do the folllowing:

``` ruby
scope :by_id, lambda{|*_values|
  _values.flat_compact_uniq!
  where(:id => _values)
}
scope :by_id_not, lambda{|*_values|
  _values.flat_compact_uniq!
  where.not(:id => _values)
}
scope :by_name_matches, lambda{|*_values|
  _values.flat_compact_uniq!
  matching(:name => _values)
}
```


# STI

Trax also has a specialized blend of STI, where you place the union of attributes in the parent table, but for the child specific attributes, you create one separate table per subclass, i.e. given the following pseudo schema
``` ruby
#(Note this may make more sense to be a has_one rather than a belongs_to, cant remember why I set it up that way)

Post
:type => string, :title => String, :attribute_set_id => (integer or uuid, this is required ATM.)

VideoPost
video_url => string
video_thumbnail => binary

TextPost
body => text
```
You would have 2 additional models

1. VideoPostAttributeSet
2. TextPostAttributeSet

Which contain the type specific columns.

Then you just need to include

``` ruby
class VideoPost < Post
  include ::Trax::Model::STI::Attributes

  sti_attribute :video_url, :video_thumbnail
end
```

STI Attribute will set up the delegation to the attribute_set model, so now you can do

``` ruby
VideoPost.new(:video_url => "http://whatever.com")
```

ETC..

AttributeSet model will be built automatically if it does not exist, and delegated to accordingly.

The idea is to hide the complexity of dealing with the attribute_set table, and do as much as possible in the main model, as its really just an extension of itself.

If you need to override one of the attribute_sets methods, try super! as that will delegate to it and call super on the attribute set model.


## Installation

Add this line to your application's Gemfile:

    gem 'trax_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trax_model

## Running Specs

Install docker

` bash
docker-compose up
bx rake db:prepare
DB=pg bx rspec
`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/trax_model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
