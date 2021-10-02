require 'json'
require 'tty-prompt'
require 'tty-table'
require 'pastel'
require 'tty-progressbar'

# The menu for entering details for getting a quote 
class Menu
    # Display a welcome message (with a command line argument if provided), and ascii art logo
    def welcome()
        prompt = TTY::Prompt.new
        pastel = Pastel.new
        name = ARGV[0]
        logo = File.read('logo.txt')
        puts pastel.yellow(logo)
        prompt.ok("Welcome to Solar App#{name ? (" " +name) : ""}! Press Control + C to quit at any time.")
        puts " "
    end
    
    # Display a menu for entering quote details
    # Validate input to ensure it works with the Quote initialize method 
    # Provide select options and "I'm not sure" to be user friendly 

    def menu()
        prompt = TTY::Prompt.new
        welcome()
        begin
            result = prompt.collect do
                key(:postcode).ask("What's your postcode?", convert: :int, required: true)
                key(:power).ask("\nWhat's your current power cost per kwh? Australian average is $0.34:", value: "0.34", convert: :float, required: true)
                key(:family).select("\nWhat's your household size?") do |menu|
                    menu.choice name: "1", value: 1
                    menu.choice name: "2", value: 2
                    menu.choice name: "3", value: 3
                    menu.choice name: "4", value: 4
                    menu.choice name: "5", value: 5
                    menu.choice name: "More than 5", value: 6
                end

                key(:orientation).select("\nWhats the main roof orientation where the solar panels will be located?") do |menu|
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
                    
                key(:pool).select("\nDo you have a pool?") do |menu|
                    menu.choice name: "No", value: false
                    menu.choice name: "Yes", value: true
                end

                key(:size).select("\nWhat size system are you interested in? \nGenerally, a larger system is recommended as the rebate is based on the solar panel output.") do |menu|
                    menu.choice name: "6.6kW - recommended for small or medium roofs", value: 6.6
                    menu.choice name: "10kW - recommended for large roofs with ~48.6m2 of space for panels", value: 10
                    menu.choice name: "15kW - recommended for very large roofs (73m2+ available space) and high energy bills", value: 15
                    menu.choice name: "20kW - recommended for very large roofs (97.22+ available space) and high energy bills", value: 20
                end

                key(:quality).select("\nWhat quality solar system (solar panels and inverter) are you intested in?") do |menu|
                    menu.choice name: "I'm not sure", value: "value"
                    menu.choice name: "Value - good value, quality components with 10 year warranty", value: "value"
                    menu.choice name: "Premium - premium brands with 15-20 year warranty and excellent service", value: "premium"
                end 

                key(:fit).ask("\nWhat feed in tarrif (exporting power to the grid) is available to you from your energy retailer? Australia's average is $0.12:", value: "0.12", convert: :float, required: true)
                key(:install_year).ask("\nWhat year will the panels be installed?", value: "#{Time.new.year }", convert: :int, required: true)
            end
        # If the user presses ctrl + c to exit (as per welcome message) it throws interrupt error   
        rescue Interrupt
            puts "\You ended the program"
        rescue 
            puts "An error occured, please try again."
        end
        return result
    end

    # Ask the user if they'd like to perform another quote
    def continue()
        prompt = TTY::Prompt.new
        prompt.yes?("What you like to calculate another solar quote?")
    end
end