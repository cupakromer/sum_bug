class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart

  attr_accessible :amount, :product

  def price
    product.price * amount
  end
end
