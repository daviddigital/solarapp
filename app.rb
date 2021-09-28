require 'json'
# require 'rainbow' todo

class Quote
    attr_reader :system

    #end date of rebate
    ENDDATE = 2031 
    STC_PRICE = 40 
    def initialize(postcode, power_type, household_size, roof_orientation, pool, 
        size, quality, feed_in_tarrif, installation_year, usage_cost)
        @property = Property.new(postcode, power_type, household_size, roof_orientation, pool)
        @system = SolarSystem.new(size, quality, feed_in_tarrif, installation_year)
        @current_bill = CurrentBill.new(usage_cost)
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
        parsed = JSON.load_file('roof_orientation.json')

    def get_system_output()
        postcode_zone = rebate_postcode(@property.postcode)[:zone]
        output = 0
        parsed = JSON.load_file('zones_to_production', symbolize_names: true)
        parsed.each do |zone|
            if zone == postcode_zone
                output = zone[:kwh] * 386 * 

        case zone
        when 1
            out = 365 * 
        
    end 
end

class Property
    attr_reader :postcode

    def initialize(postcode, power_type, household_size, roof_orientation, pool)
        @postcode = postcode
        @power_type = power_type
        @household_size = household_size
        @roof_orientation = roof_orientation
        @pool = pool
    end
end

class SolarSystem
    attr_reader :size, :installation_year

    def initialize(size, quality, feed_in_tarrif, installation_year)
        @size = size
        @quality = quality
        @feed_in_tarrif = feed_in_tarrif
        @installation_year = installation_year 
    end

    def get_system_cost()
        parsed = JSON.load_file('system_prices.json', symbolize_names: true)
        cost = 0.0
        parsed.each do |system|
            if system[:quality] == @quality && system[:size].to_f == @size.to_f
                cost = system[:cost].to_f
            end
        end
        return cost
    end
end

class CurrentBill
    def initialize(usage_cost)
        @usage_cost = usage_cost
    end

    def get_average_usage
    end 
end

new_quote = Quote.new(4000, "single-phase", 2, "N", false, 10, "value", 0.20, 2021, 0.24)
p "Solar system cost: #{new_quote.system.get_system_cost()}"
p "Solar system rebate: #{new_quote.rebate_amount()}"
p "Solar system output: #{new_quote.get_system_output()}"