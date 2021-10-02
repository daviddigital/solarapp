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