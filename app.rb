require 'json'
require 'tty-prompt'
require 'tty-table'
require 'pastel'

# require 'rainbow' todo

# new_quote = Quote.new(4000, "single-phase", 0.24, 6, "N", true, 6.6, "value", 0.20, 2021)

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

    # Example rebate: A 10kW system in postcode 4000 installed in 2020
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
        # prompt.ok "Payback period: #{payback_period()}"  Array can't be coerced into Float (TypeError) 

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
        pastel = Pastel.new
        puts pastel.green("Property Details")
        puts property_table.render(:ascii)
        puts pastel.green("Solar System Details")
        puts system_table.render(:ascii)
        puts pastel.green("Costs and Benefits")
        puts costs_table.render(:ascii)
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