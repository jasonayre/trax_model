# TraxModel

A composeable companion to active record models. Just include ::Trax::Model and you're off to the races.

The biggest feature of this library at the moment is its support for uuids:

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
