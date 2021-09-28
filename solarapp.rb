require_relative './app.rb'
require 'tty-prompt'

def menu()
    prompt = TTY::Prompt.new
    prompt.ok("Welcome to Solar App! At any time you can exit using Control-C")

    result = prompt.collect do
        key(:postcode).ask("What's your postcode?", convert: :int)
        key(:power).ask("What's your current power cost per kwh?", value: "0.24", convert: :float)
        key(:family).select("What's your household size?", %w(1 2 3 4 5 5+))
        
        key(:orientation).select("Whats the main roof orientation where the solar panels will be located?") do |menu|
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
            
        
        ## Todo convert: :bool not working on pool https://github.com/piotrmurach/tty-prompt#ttyprompt-
        key(:pool).select("Do you have pool?") do |menu|
            menu.choice name: "No", value: false
            menu.choice name: "Yes", value: true
        end

        key(:size).select("What size system are you interested in?", %w(6.6 10 15 20), convert: :float)
        key(:quality).select("What quality system are you intested in?", %w(Value Quality))
        key(:fit).ask("What feed in tarrif is available to you?", value: "$0.20")
        key(:install_year).ask("What year will the panels be installed?", value: "#{Time.new.year }")
    end
    return result
end 
result = menu()
p result
# create an instance of Quote

new_quote = Quote.new(result[:postcode], result[:power], 6, "N", true, 6.6, "value", 0.20, 2021)
new_quote.output()

# Add an option to log to a csv

# Add a message to prompt with a link to gihub readme anchor on list of assumptions for data