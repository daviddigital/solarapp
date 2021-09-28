require 'json'
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
                return zone[:kwh] * 365 * orientation_factor() * @system.size
            end
        end
    end

    def bill_after_solar()
        current_bill_usage = @property.current_bill()[0]
        system_output = get_system_output()
        if system_output > current_bill_usage
            return [(@property.current_bill()[1] - system_output * @property.power_cost) + ((system_output - current_bill_usage) * @system.feed_in_tarrif), ((system_output - current_bill_usage) * @system.feed_in_tarrif)]
        else 
            return @property.current_bill()[1] - system_output * @property.power_cost
        end
    end

    def payback_period()
        return (@system.get_system_cost() - rebate_amount())/(@property.current_bill()[1] - bill_after_solar())
    end
end

class Property
    attr_reader :postcode, :roof_orientation, :power_cost

    def initialize(postcode, power_cost, household_size, roof_orientation, pool)
        @postcode = postcode
        @power_cost = power_cost
        @household_size = household_size
        @roof_orientation = roof_orientation
        @pool = pool
    end

    def current_bill()
        # TODO, ENSURE 5+ is passed as 6 from menu
        
        annual_consumption = 0
        parsed = JSON.load_file('consumption_by_household.json', symbolize_names: true)
        parsed.each do |household|
            if household[:household] == @household_size && household[:pool] == @pool
                annual_consumption = household[:consumption] * 365
                return [annual_consumption, annual_consumption * @power_cost]
            end 
        end
    end
end

class SolarSystem
    attr_reader :size, :installation_year, :feed_in_tarrif

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
                return system[:cost].to_f
            end
        end
    end
end


# new_quote = Quote.new(4000, "single-phase", 0.24, 6, "N", true, 6.6, "value", 0.20, 2021)
# p "Solar system cost: $#{new_quote.system.get_system_cost()}"
# p "Solar system rebate: $#{new_quote.rebate_amount()}"
# p "Solar system output: #{new_quote.get_system_output()} kwh "
# p "Solar system current bill: #{new_quote.property.current_bill()} (kwh / $) "
# p "Solar system bill after solar: #{new_quote.bill_after_solar()}"
# p "Payback period: #{new_quote.payback_period}"