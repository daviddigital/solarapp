require_relative './app.rb'
require 'tty-prompt'

prompt = TTY::Prompt.new
prompt.ok("Welcome to Solar App! At any time you can exit using Control-C")

result = prompt.collect do
    key(:postcode).ask("What's your postcode?", convert: :int)
    key(:power).ask("What's your current power cost per kwh?", value: "0.24", convert: :float)
    key(:family).select("What's your household size?", %w(1 2 3 4 5 5+))
    key(:orientation).select("Whats the main roof orientation where the solar panels will be located?", %w(North North-East East East-West West South-West East-And-West Unsure/Other))
    
    ## Todo convert: :bool not working on pool https://github.com/piotrmurach/tty-prompt#ttyprompt-
    key(:pool).select("Do you have pool?", %w(yes no))
    key(:size).select("What size system are you interested in?", %w(6.6 10 15 20), convert: :float)
    key(:quality).select("What quality system are you intested in?", %w(Value Quality))
    key(:fit).ask("What feed in tarrif is available to you?", value: "$0.20")
    key(:install_year).ask("What year will the panels be installed?", value: "#{Time.new.year }")
end

p result

# create an instance of Quote

new_quote = Quote.new(result[:postcode], 0.24, 6, "N", true, 6.6, "value", 0.20, 2021)
prompt.ok "Your solar system"
prompt.ok "Solar system cost: $#{new_quote.system.get_system_cost()}"
prompt.ok "Solar system rebate: $#{new_quote.rebate_amount()}"
prompt.ok "Solar system output: #{new_quote.get_system_output()} kwh"
prompt.ok "Solar system current bill: #{new_quote.property.current_bill()} (kwh / $)"
prompt.ok "Solar system bill after solar: #{new_quote.bill_after_solar()}"
prompt.ok "Payback period: #{new_quote.payback_period}"