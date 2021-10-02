require 'test/unit'
require 'json'
require_relative 'classes/property.rb'

class QuoteTest < Test::Unit::TestCase
    def setup
        @new_property = Property.new(4000, 0.30, 2, "N", false)
    end
    # Test the property is initialised 
    def test_create
        assert_not_nil(@new_property)
    end

    def test_postcode
        assert_equal(4000, @new_property.postcode)
    end

    def test_power
        assert_equal(0.30, @new_property.power_cost)
    end

    def test_household
        assert_equal(2, @new_property.household_size)
    end

    def test_orientation
        assert_equal("N", @new_property.roof_orientation)
    end

    def test_pool
        assert_equal(false, @new_property.pool)
    end

    # Test the current bill based on the number of adults (2), the postcode(4000) and the cost per kwh (0.30)

    def test_bill
        assert_equal(140.53, @new_property.current_bill()[:bill].round(2))
    end
end