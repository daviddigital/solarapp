require 'json'
# require 'rainbow' todo

class Quote
    attr_reader :system
    def initialize(postcode, power_type, household_size, roof_orientation, pool, 
        size, quality, feed_in_tarrif, usage_cost)
        @property = Property.new(postcode, power_type, household_size, roof_orientation, pool)
        @system = SolarSystem.new(size, quality, feed_in_tarrif)
        @current_bill = CurrentBill.new(usage_cost)
    end
end

class Property
    def initialize(postcode, power_type, household_size, roof_orientation, pool)
        @postcode = postcode
        @power_type = power_type
        @household_size = household_size
        @roof_orientation = roof_orientation
        @pool = pool
    end
end

class SolarSystem
    def initialize(size, quality, feed_in_tarrif)
        @size = size
        @quality = quality
        @feed_in_tarrif = feed_in_tarrif
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
end

new_quote = Quote.new(4000, "single-phase", 2, "N", false, 10, "value", 0.20, 0.24)
p new_quote.system.get_system_cost()



