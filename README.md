# Trax Model

A composeable companion to active record models. Just include ::Trax::Model and you're off to the races.

### UUIDS

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

I.E.

``` ruby
class Product < ActiveRecord::Base
  include ::Trax::Model
  defaults :uuid_prefix => "0a"
end
```

``` ruby
Product.new

=> #<Product id: nil, name: nil, category_id: nil, user_id: nil, price: nil, in_stock_quantity: nil, on_order_quantity: nil, active: nil, uuid: "0a97ad3e-1673-41f3-b356-d62dd53629d8", created_at: nil, updated_at: nil>
```

### Get next available prefix, useful when setting models up

``` ruby
bx rails c
::Trax::Model::Registry.next_prefix
=> "1a"
```

### Or, register prefixes using dsl rather than in each individual class

``` ruby

Trax::Model::UUID.register do
  prefix "1a", Product
  prefix "1b", Category
end
```

But wait theires more!

### UUID utility methods

``` ruby
product_uuid = Product.first.uuid
=> "0a97ad3e-1673-41f3-b356-d62dd53629d8"

product_uuid.record_type
=> Product
product_uuid.record
```

will return the product instance

Which opens up quite a few possibilites via the newfound discoverability of your uuids...

# MTI (Multiple Table Inheritance)

### Note: you must use Trax UUIDS w/ prefixes to use this feature (as we map each entity to its specific table, via the prefixed uuid.

Going to be a very brief documentation but:

### Set up MTI structure like this:
```
models/post.rb (your entity model)
models/post_types/abstract.rb (abstract, inherit from this)
models/post_types/entity.rb
models/post_types/video.rb
models/post_types/text.rb
models/post_types/audio.rb
```

Post is your entity class, entity is essentially a flat table which contains a list of
any common attributes, as well as the ids for each of your MTI data models. The beauty
of this, is that since Trax model uuids tell us what type the record is, we don't
need to use STI, or have a type column to determine the type of the record.

Basically, the entity model when loaded, will eager load the real model. If the real model is created, updated, or destroyed, a callback will ensure that the corresponding entity record is kept in sync.

``` ruby
module Blog
  class Post < ActiveRecord::Base
    include ::Trax::Model::MTI::Entity

    mti_namespace ::Blog::Posts
  end
end

#no database table to this class as its abstract.
module Blog
  module Posts
    class Abstract < ::ActiveRecord::Base
      # following line sets abstract_class = true when including module
      include ::Trax::Model::MTI::Abstract

      entity_model :class_name => "Blog::Post"

      ### Define your base inherited logic / methods here ###

      belongs_to :user_id
      belongs_to :category_id

      validates :user_id
      validates :category_id
    end
  end
end

module Blog
  module Posts
    class Video < ::Blog::Posts::Abstract

    end
  end
end
```

### MTI VS STI

The main advantages of Multiple Table Inheritance versus Single Table inheritance I see are:

1. Table size. As databases grow, vertically adding more length to traverse the table will continue to get slower. One way to mitigate this issue would be to split up your table into multiple horizontal tables, if it makes sense for your data structure to do so (i.e. like above)

2. STI will get out of proportion likely. I.e. if 90% of your posts are text posts, then when you are looking for a video post, you are to some degree being slowed down by the video posts in your table. (or at least at some point when you reach past xxxxxx number of records)

3. Further on that note, only storing what you need for each individual subset of your data, on that particular subset. I.e. if video post has a video_url attribute, but none of the other post types have that, it will keep holes out of your data tables since video_url is only on the video_posts table.

4. Real separation at the data level of non common attributes, so you dont have to write safeguards in child classes to make sure that a value didnt slip into a field or whatever, because each child class has its own individual interpretation of the schema.

The main disadvantages are:

1. No shared view between child types. I.E. thats what the MTI entity is for. (want to find all blog posts? You cant unless you select a type first, or are using this gem, or a postgres view or something else)
2. More difficult to setup since each child table needs its own table.


## Installation

Add this line to your application's Gemfile:

    gem 'trax_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install trax_model

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/trax_model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
