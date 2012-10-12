```ruby
class Cart < ActiveRecord::Base
  has_many :line_items

  def total
    line_items.sum(&:price)
  end
end

class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart

  attr_accessible :years, :product

  def price
    product.price * years
  end
end

cart = Cart.new
cart.line_items.build do
  # stuff...
end

cart.line_items.sum(&:price)
#=> TypeError: nil can't be coerced into BigDecimal

cart.line_items.to_a.sum(&:price)
#=> #<BigDecimal:7ff4d34ca7c8,'0.0',9(36)>

cart.line_items.map(&:price).sum
#=> #<BigDecimal:7ff4d3373b40,'0.0',9(36)>
```

It seems in (Rails 3.2.8, Ruby 1.9.3) that `has_many` is creating
[`collection.sum`](https://github.com/rails/rails/blob/959fb8ea651fa6638aaa7caced20d921ca2ea5c1/activerecord/lib/active_record/associations/collection_association.rb#L181).
According to the code, it will always try to hit the database using a SQL `sum`.
However, in this particular instance, the model isn't saved. So there's nothing
in the database. I would think it should pull from the cached copy.

Also, there is the potential where the `model` is saved, but the `collection`
was modified but not saved yet (i.e. with a `build`); this could cause
un-expected sums.

Line 25 in the code throws an error due to the DB (PostgreSQL) but with
Sqlite it just returns 0.

Tests are in test/unit/cart_test.rb

To reproduce this issue:

  * Clone this repo
  * Run `bundle`
  * Run `rake`
