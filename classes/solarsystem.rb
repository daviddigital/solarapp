#This is called by the Quote class which creates this property using composition
class SolarSystem
    attr_reader :size, :installation_year, :feed_in_tarrif, :quality

    def initialize(size, quality, feed_in_tarrif, installation_year)
        @size = size
        @quality = quality
        @feed_in_tarrif = feed_in_tarrif
        @installation_year = installation_year
    end

    # Get the system cost based on the size and quality from the json file
    def get_system_cost()
        parsed = JSON.load_file('system_prices.json', symbolize_names: true)
        parsed.each do |system|
            if system[:quality] == @quality && system[:size].to_f == @size.to_f
                return system
            end
        end
    end
end