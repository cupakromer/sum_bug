class Cart < ActiveRecord::Base
  has_many :line_items

  def total
    line_items.sum(&:price)
  end
end
