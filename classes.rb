require 'json'
require 'tty-prompt'
require 'tty-table'
require 'pastel'
require 'tty-progressbar'

class Menu
    def menu()
        prompt = TTY::Prompt.new
        pastel = Pastel.new
        logo = File.read('logo.txt')
        puts pastel.yellow(logo)
        prompt.ok("Welcome to Solar App! Press Control + C to quit at any time.")

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
        return result
    end

    # Purpose is to ask the user if they'd like to perorm another quote
    def continue()
        prompt = TTY::Prompt.new
        prompt.yes?("What you like to calculate another solar quote?")
    end
end

class Quote
    attr_reader :system, :property

    #end date of rebate
    ENDDATE = 2031 
    STC_PRICE = 40 
    def initialize(postcode, power_cost, household_size, roof_orientation, pool, 
        size, quality, feed_in_tarrif, installation_year)
        @property = Property.new(postcode, power_cost, household_size, roof_orientation, pool)
        @system = SolarSystem.new(size, quality, feed_in_tarrif, installation_year)
    end

    # CALCULATION Example rebate: A 10kW system in postcode 4000 installed in 2020
    # 10 * 1.382 * (2031-2021) = 138 STCs
    # 2031 is the year the scheme ends

    def rebate_amount()
        rebate_postcode = rebate_postcode(@property.postcode)
        stcs = (@system.size * rebate_postcode[:rating] * (ENDDATE - @system.installation_year)).round
        return stcs * STC_PRICE
    end

    def rebate_postcode(postcode)
        hash = {}
        parsed = JSON.load_file('postcodes_to_zones.json', symbolize_names: true)
        parsed.each do |postcode_range|
            if postcode >= postcode_range[:postcode_from] && postcode <= postcode_range[:postcode_to]
                hash[:zone] = postcode_range[:Zone]
                hash[:rating] = postcode_range[:Rating]
            end
        end
        return hash
    end

    def orientation_factor()
        parsed = JSON.load_file('roof_orientation.json', symbolize_names: true)
        parsed.each do |orientation|
            if orientation[:facing] == @property.roof_orientation
                return orientation[:factor]
            end
        end
    end

    def get_system_output()
        postcode_zone = rebate_postcode(@property.postcode)[:zone]
        parsed = JSON.load_file('zones_to_production.json', symbolize_names: true)
        parsed.each do |zone|
            if zone[:zone] == postcode_zone
                return zone[:kwh] * 365 * orientation_factor() * @system.size / 12
            end
        end
    end

    def bill_after_solar()
        current_bill_usage = @property.current_bill()[:consumption]
        system_output = get_system_output()
        if system_output > current_bill_usage
            new_bill = -((system_output - current_bill_usage) * @system.feed_in_tarrif)
            return {:credit => true, :newbill => new_bill}
        else 
            new_bill = @property.current_bill()[:bill] - system_output * @property.power_cost
            return {:credit => false, :newbill => new_bill}
        end
    end

    def system_cost_after_rebate()
        @system.get_system_cost()[:cost].to_f - rebate_amount()
    end

    def payback_period()
        cost = system_cost_after_rebate()
        yearly_benefit = (@property.current_bill()[:bill] * 12) - (bill_after_solar()[:newbill] * 12)
        return cost / yearly_benefit
    end

    def output()

        property_table_data = 
        [
            ["Postcode", "#{@property.postcode}"],
            ["Household size", "#{@property.household_size}"],
            ["Pool", "#{(@property.pool ? "Yes" : "No")}"],
            ["Roof orientation", "#{@property.roof_orientation}"]
        ]

        system_table_data =
        [
            ["Category", "#{@system.quality}"],
            ["System size", "#{@system.size}kW"],
            ["Solar panels", "#{system.get_system_cost()[:"panels-brand"]}"],
            ["Solar Inverter", "#{system.get_system_cost()[:"inverter-brand"]}"],
            ["Other", "CEC Accredited installer"]
        ]
        costs_table_data =
        [
            ["Upfront installation costs", "$#{'%.2f' % system_cost_after_rebate()} (after rebate)"],
            ["Monthly Bill (before solar)", "$#{'%.2f' % @property.current_bill()[:bill]}"],
            ["Monthly Bill (after solar)", "$#{'%.2f' % bill_after_solar()[:newbill]} #{(bill_after_solar()[:credit] ? "(CREDIT)" : "")}"], 
            ["Payback period", "#{'%.2f' % payback_period()} years"]
        ]
        property_table = TTY::Table.new(property_table_data)
        system_table = TTY::Table.new(system_table_data)
        costs_table = TTY::Table.new(costs_table_data)
        output_loading()
        pastel = Pastel.new
        puts pastel.green("Property Details")
        puts property_table.render(:ascii)
        puts pastel.green("Solar System Details")
        puts system_table.render(:ascii)
        puts pastel.green("Costs and Benefits")
        puts costs_table.render(:ascii)
    end

    # Display a loading bar  
    def output_loading()
        pastel = Pastel.new
        green = pastel.on_green(" ")
        yellow = pastel.on_yellow(" ")
        
        puts " "
        bar = TTY::ProgressBar.new("Preparing Quote [:bar]", 
            total: 30,
            complete: green,
            incomplete: yellow
        )
        30.times do
            sleep(0.05)
            bar.advance
        end
        puts " "
        puts pastel.magenta("------RESULTS------")
        puts " "
    end
end

class Property
    attr_reader :postcode, :power_cost, :household_size, :roof_orientation, :pool

    def initialize(postcode, power_cost, household_size, roof_orientation, pool)
        @postcode = postcode
        @power_cost = power_cost
        @household_size = household_size
        @roof_orientation = roof_orientation
        @pool = pool
    end

    def current_bill()
        annual_consumption = 0
        parsed = JSON.load_file('consumption_by_household.json', symbolize_names: true)
        parsed.each do |household|
            if household[:household] == @household_size && household[:pool] == @pool
                consumption = household[:consumption] * 365 / 12
                bill = consumption * @power_cost
                return {:consumption => consumption, :bill => bill}
            end 
        end
    end
end

class SolarSystem
    attr_reader :size, :installation_year, :feed_in_tarrif, :quality

    def initialize(size, quality, feed_in_tarrif, installation_year)
        @size = size
        @quality = quality
        @feed_in_tarrif = feed_in_tarrif
        @installation_year = installation_year
    end

    def get_system_cost()
        parsed = JSON.load_file('system_prices.json', symbolize_names: true)
        parsed.each do |system|
            if system[:quality] == @quality && system[:size].to_f == @size.to_f
                return system #[:cost].to_f
            end
        end
    end
end