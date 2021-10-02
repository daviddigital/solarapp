require 'test/unit'
require 'json'
require_relative 'classes/property.rb'
require_relative 'classes/quote.rb'
require_relative 'classes/solarsystem.rb'

class QuoteTest < Test::Unit::TestCase
    # Set up a quote instance with some example input.
    def setup
        @new_quote = Quote.new(4000, 0.30, 2, "N", false, 10, "value", 0.12, 2021)
    end
    # Test the quote is created correctly from the menu inputs.
    def test_create
        assert_not_nil(@new_quote)
    end

    def test_postcode
        assert_equal(4000, @new_quote.property.postcode)
    end

    def test_power
        assert_equal(0.30, @new_quote.property.power_cost)
    end

    def test_household
        assert_equal(2, @new_quote.property.household_size)
    end

    def test_orientation
        assert_equal("N", @new_quote.property.roof_orientation)
    end

    def test_pool
        assert_equal(false, @new_quote.property.pool)
    end

    def test_size
        assert_equal(10, @new_quote.system.size)
    end
    def test_quality
        assert_equal("value", @new_quote.system.quality)
    end
    def test_installation
        assert_equal(2021, @new_quote.system.installation_year)
    end
    
    # Test the rebate is correct based on postcodes_to_zones.json
    # CALCULATION Example rebate: A 10kW system in postcode 4000 installed in 2021
    # 10 * 1.382 * (2031-2021) = 138 STCs
    # 2031 is the year the scheme ends
    # 138 STCs * $40 = $5520
    def test_rebate
        assert_equal(5520, @new_quote.rebate_amount())
    end
    # Test the upfront price after rebate is correct based on system_prices.json
    # CALCULATION $12,000 should be the cost for a value 10kw system, $5520 is the rebate
    # 12000 - 5520 = 6840
    def test_price
        assert_equal(6480.0, @new_quote.system_cost_after_rebate)
    end

    # Test the packback period of intiial 6840 after the reduction in bills
    def test_payback
        assert_equal(2.27, @new_quote.payback_period.round(2))
    end
   
end