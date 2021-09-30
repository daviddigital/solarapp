require_relative './app.rb'
require 'tty-prompt'

def menu()
    prompt = TTY::Prompt.new
    prompt.ok("Welcome to Solar App! Press Control + C to quit at any time.")

    result = prompt.collect do
        key(:postcode).ask("What's your postcode?", convert: :int)
        key(:power).ask("What's your current power cost per kwh? Australian average is $0.34:", value: "0.34", convert: :float)
        key(:family).select("What's your household size?") do |menu|
            menu.choice name: "1", value: 1
            menu.choice name: "2", value: 2
            menu.choice name: "3", value: 3
            menu.choice name: "4", value: 4
            menu.choice name: "5", value: 5
            menu.choice name: "More than 5", value: 6
        end

        key(:orientation).select("Whats the main roof orientation where the solar panels will be located?") do |menu|
            menu.choice name: "I'm not sure", value: "NE"
            menu.choice name: "North", value: "N"
            menu.choice name: "North-East", value: "NE"
            menu.choice name: "East", value: "E"
            menu.choice name: "South-East", value: "SE"
            menu.choice name: "South", value: "S"
            menu.choice name: "South-West", value: "SW"
            menu.choice name: "West", value: "W"
            menu.choice name: "North-West", value: "NW"
            menu.choice name: "North and South", value: "NS"
            menu.choice name: "East and West", value: "EW"
        end
            
        key(:pool).select("Do you have a pool?") do |menu|
            menu.choice name: "No", value: false
            menu.choice name: "Yes", value: true
        end

        key(:size).select("What size system are you interested in? \nGenerally, bigger is better as the rebate is based on the solar panel output.") do |menu|
            menu.choice name: "6.6kW - recommended for small or medium roofs", value: 6.6
            menu.choice name: "10kW - recommended for large roofs with ~48.6m2 of space for panels", value: 10
            menu.choice name: "15kW - recommended for very large roofs (73m2+ available space) and high energy bills", value: 15
            menu.choice name: "20kW - recommended for very large roofs (97.22+ available space) and high energy bills", value: 20
        end

        key(:quality).select("What quality solar system (solar panels and inverter) are you intested in?") do |menu|
            menu.choice name: "I'm not sure", value: "value"
            menu.choice name: "Value - good value, quality components with 10 year warranty and high output", value: "value"
            menu.choice name: "Premium - same output as Value but premium (expensive) brands with 15-20 year warranty and excellent service", value: "premium"
        end 

        key(:fit).ask("What feed in tarrif (exporting power to the grid) is available to you from your energy retailer? \nThis can range from $0.06 to $0.20 per kWh:", value: "0.12", convert: :float)
        key(:install_year).ask("What year will the panels be installed?", value: "#{Time.new.year }", convert: :int)
    end
    return result
end 
result = menu()
# create an instance of Quote

new_quote = Quote.new(result[:postcode], result[:power], result[:family], result[:orientation], result[:pool], result[:size], result[:quality], result[:fit], result[:install_year])

new_quote.output()

# new_quote = Quote.new(4000, "single-phase", 0.24, 6, "N", true, 6.6, "value", 0.20, 2021)
