require 'test_helper'

class CartTest < ActiveSupport::TestCase # test "the truth" do
  def setup
    @product = Product.create! name: "Ruby shirt", price: 2.25
  end

  test "new cart's total should sum line items" do
    cart = Cart.new
    cart.line_items.build do |line_item|
      line_item.amount = 2
      line_item.product = @product
    end

    assert_equal BigDecimal.new('4.50').to_s, cart.total.to_s
  end

  test "new cart should allow summing from cart.line_items" do
    cart = Cart.new
    cart.line_items.build do |line_item|
      line_item.amount = 2
      line_item.product = @product
    end

    assert_equal BigDecimal.new('4.50').to_s, cart.line_items.sum(&:price).to_s
  end

  test "existing cart's total should sum line items" do
    cart = Cart.create!
    cart.line_items << LineItem.create!(amount: 3, product: @product)

    assert_equal BigDecimal.new('6.75').to_s, cart.line_items.sum(&:price).to_s
    assert_equal BigDecimal.new('6.75').to_s, cart.total.to_s
  end

  test "existing cart should include new line item in total" do
    cart = Cart.create!
    cart.line_items << LineItem.create!(amount: 3, product: @product)
    cart.line_items.build do |line_item|
      line_item.amount = 2
      line_item.product = @product
    end

    assert_equal BigDecimal.new('11.25').to_s, cart.line_items.sum(&:price).to_s
    assert_equal BigDecimal.new('11.25').to_s, cart.total.to_s
  end
end
