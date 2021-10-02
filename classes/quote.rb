require 'json'
require 'tty-prompt'
require 'tty-table'
require 'pastel'
require 'tty-progressbar'
require_relative 'property'
require_relative 'menu'
require_relative 'solarsystem'

# Build a quote based on the menu inputs for a property and system 
class Quote
    attr_reader :system, :property

    # End date of rebate as per Australian Energy Regulator
    ENDDATE = 2031 

    # STC price as per Australian Energy Regulator, this doesn't change. 
    # In relatity may be slightly less due to secondary market, but in ballpark 
    STC_PRICE = 40 
    def initialize(postcode, power_cost, household_size, roof_orientation, pool, 
        size, quality, feed_in_tarrif, installation_year)
        @property = Property.new(postcode, power_cost, household_size, roof_orientation, pool)
        @system = SolarSystem.new(size, quality, feed_in_tarrif, installation_year)
    end

    # Rebate is based on the postcode zones, which are linked in the file
    # See quote_test.rb for an example rebate with workings
    def rebate_amount()
        begin
            rebate_postcode = rebate_postcode(@property.postcode)
            stcs = (@system.size * rebate_postcode[:rating] * (ENDDATE - @system.installation_year)).round
        rescue
            puts "Postcode not found, please try again"
            exit
        end    
        return stcs * STC_PRICE
    end

    # Find the correct zone to help the rebate_amount() method 
    def rebate_postcode(postcode)
        hash = {}
        parsed = JSON.load_file('postcodes_to_zones.json', symbolize_names: true)
        begin
            parsed.each do |postcode_range|
                if postcode >= postcode_range[:postcode_from] && postcode <= postcode_range[:postcode_to]
                    hash[:zone] = postcode_range[:Zone]
                    hash[:rating] = postcode_range[:Rating]
                end
            end
        rescue
            puts "Postcode not found, please try again."
            exit
        end
        return hash
    end

    # North facing roofs will generate more power, South will provide the least
    # This method retruns the factor, e.g. 105% for a north facing roof, 85% for south
    def orientation_factor()
        parsed = JSON.load_file('roof_orientation.json', symbolize_names: true)
        parsed.each do |orientation|
            if orientation[:facing] == @property.roof_orientation
                return orientation[:factor]
            end
        end
    end

    # Gets the system output based on the postcode / zone 
    # json file is daily so need to multiply by 365, add a factor for roof orientation and divide by 12
    # to return monthly output (for determining monthly bill)
    def get_system_output()
        postcode_zone = rebate_postcode(@property.postcode)[:zone]
        parsed = JSON.load_file('zones_to_production.json', symbolize_names: true)
        parsed.each do |zone|
            if zone[:zone] == postcode_zone
                return zone[:kwh] * 365 * orientation_factor() * @system.size / 12
            end
        end
    end

    # Determines the monthly bill after solar, which includes the feed in tarrif (exporting power to grid)
    # Also returns if the bill is in credit not for formatting in the table

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

    # Finds the system cost after rebate by subtracting the rebate from the system cost, to be used in output table

    def system_cost_after_rebate()
        return @system.get_system_cost()[:cost].to_f - rebate_amount()
    end

    # Payback period is how many years until the difference in bills pre/post solar equals the upfront cost
    def payback_period()
        cost = system_cost_after_rebate()
        yearly_benefit = (@property.current_bill()[:bill] * 12) - (bill_after_solar()[:newbill] * 12)
        return cost / yearly_benefit
    end

    # Display the output from the quote using tty-table gem

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
            ["Upfront installation costs (after rebate of #{rebate_amount()})", "$#{'%.2f' % system_cost_after_rebate()}"],
            ["Avg Monthly Bill (before solar)", "$#{'%.2f' % @property.current_bill()[:bill]}"],
            ["Avg Monthly Bill (after solar)", "$#{'%.2f' % bill_after_solar()[:newbill]} #{(bill_after_solar()[:credit] ? "(CREDIT)" : "")}"], 
            ["Payback period (until upfront cost is returned)", "#{'%.2f' % payback_period()} years"]
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

    # Display a loading bar with a fake load time
    
    def output_loading()
        pastel = Pastel.new
        green = pastel.on_green(" ")
        yellow = pastel.on_yellow(" ")
        
        puts " "
        bar = TTY::ProgressBar.new("Preparing Quote [:bar]", 
            bar_format: :box,
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