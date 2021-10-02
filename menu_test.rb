require 'test/unit'
require_relative 'classes/menu.rb'

class QuoteTest < Test::Unit::TestCase
    def setup
        @new_menu = Menu.new()
    end
    # Test the menu is initialised 
    def test_create
        assert_not_nil(@new_menu)
    end

end