require_relative './classes.rb'

# Create a Menu instance and display a menu that returns details for a solar quote 
new_menu = Menu.new()
result = new_menu.menu()

# Create an instance of quote with menu inputs
new_quote = Quote.new(result[:postcode], result[:power], result[:family], result[:orientation], result[:pool], result[:size], result[:quality], result[:fit], result[:install_year])

# display formatted 
new_quote.output()
