module Spree
  class Price < Spree::Base
    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', touch: true

    validate :check_price
    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }

    scope :currently_valid, -> { where(is_default: true) }
    scope :with_default_attributes, -> { where(Spree::Config.default_pricing_options.desired_attributes) }
    after_save :set_default_price

    extend DisplayMoney
    money_methods :amount, :price
    alias_method :money, :display_amount

    self.whitelisted_ransackable_attributes = ['amount']

    # An alias for #amount
    def price
      amount
    end

    # Sets this price's amount to a new value, parsing it if the new value is
    # a string.
    #
    # @param price [String, #to_d] a new amount
    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end

    private

    def check_price
      self.currency ||= Spree::Config[:currency]
    end

    def set_default_price
      if is_default?
        other_default_prices = variant.prices.currently_valid.where(pricing_options.desired_attributes).where.not(id: id)
        other_default_prices.update_all(is_default: false)
      end
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_price(self)
    end
  end
end
