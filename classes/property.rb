require 'json'

#This is called by the Quote class which creates this property using composition
class Property
    attr_reader :postcode, :power_cost, :household_size, :roof_orientation, :pool

    def initialize(postcode, power_cost, household_size, roof_orientation, pool)
        @postcode = postcode
        @power_cost = power_cost
        @household_size = household_size
        @roof_orientation = roof_orientation
        @pool = pool
    end

    # Return the current average estimated bill based on the data source (which looks at whether there is a pool and number of adults)
    # Pool is important because they use a lot of power
    # We calculate the average bill rather than the user having to search through 12 months of bills. The most recent bill may
    # Not be indicative of the entire year due to more heating or cooling 
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