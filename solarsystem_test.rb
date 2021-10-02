require 'test/unit'
require 'json'
require_relative 'classes/solarsystem.rb'

class QuoteTest < Test::Unit::TestCase
    def setup
        @new_solar = SolarSystem.new(10, "value", 0.12, 2021)
    end
    # Test the solar system is initialised 
    def test_create
        assert_not_nil(@new_solar)
    end

    def test_size
        assert_equal(10, @new_solar.size)
    end

    def test_quality
        assert_equal("value", @new_solar.quality)
    end

    def test_fit
        assert_equal(0.12, @new_solar.feed_in_tarrif)
    end

    def test_installation_year
        assert_equal(2021, @new_solar.installation_year)
    end
    # Test a 10kw value system is $12000
    def test_price
        assert_equal(12000, @new_solar.get_system_cost()[:cost].to_f)
    end
end