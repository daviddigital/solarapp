require_relative './classes/menu.rb'
require_relative './classes/quote.rb'

def run()
    continue = true

    while continue
        # Create a Menu instance and display a menu that returns details for a solar quote 
        new_menu = Menu.new()
        result = new_menu.menu()

        # Create an instance of quote with menu inputs, check the user didn't exit the menu
        if result
            new_quote = Quote.new(result[:postcode], result[:power], result[:family], result[:orientation], result[:pool], result[:size], result[:quality], result[:fit], result[:install_year])

            # display formatted 
            new_quote.output()

            #ask user if they'd like to get another quote
            continue = new_menu.continue()
        else 
            break
        end
    end
end

run()