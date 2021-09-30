# Statement of purpose and scope

## Overview

Solar App is an a command line application that users can use to find out the costs and benefits of installing solar panels in Australia.

The app will take an address and other input data such as power usage and solar power system size, and determine the costs and savings after any available rebates available in the user's state.

## Scope

The scope of this App is for residential users in Australia who are making use of solar/carbon credits available to them, known as small-scale certificates (STCs).

Where available APIs will be used to determine current STC prices.

The App will determine a high level estimate and will assume 

## Problem Statement

Without Solar App it can be hard to determine whether a solar system is worth the investment, and what size solar system to install.

Currently, individuals can reach out to installers for free quotes, but installers have an incentive to get the customer and some solar installers can be pushy.

Online calculators exist for Solar but they can use confusing terminology and require a lot of input upfront like existing power bill information. 

## Target Audience
 
The primary inteded user of the app are individuals interested in getting solar installed on their roof and want to perform a quick check as to whether the benefits outweigh the costs. A secondary user could be solar retailers who are preparing a quote for a client. 

## Example Use Case

John is interested in getting solar on his roof and wants to find out the costs and benefits without needing to contact an installer.

John runs Solar App, which prompts John for the following inputs:

- What is the postcode of the property
- What is the installation year (defaulted to current year)
- Power: Single-Phase, Three-Phase or I don't know 
- Number of people at the property: 1, 2, 3, 4, 5+
- Solar System Size: 6.6kW, 10kW, 15kW, 20kW
- Solar System Quality: Value for money, premium, or enter your own price
- Main roof orientation (N, E, S, W) (optional )
- Current monthly power bill (optional)
- Current power cost (optional)
- Feed In Tarrif (optional)

Solar App outputs the following to John:

- The upfront cost for the solar system(s)
- The benefits after one year, thee years, five years and ten years broken up as reduced bills as well as credits from feeding into the grid
- Solar bill before and after solar
- Assumptions used in the analysis  

# Features 

## 1. Ability to enter information quote from a Menu

Solar App will take the following inputs via a menu which will assist in determining the costs and benefit outputs. 

1. Postcode
2. Installation year (defaulted to current year)
3. Power type (single phase or three phase)
4. Number of people at the property
5. Solar System Size
6. Solar System Quality
7. Main roof orientation 
8. Current monthly power bill
9. Current power cost
10. Feed in tarrif 

Error checking will be utilised to ensure clean data is captured (e.g. valid postcodes, 4 numberical characters). 

## 2. Ability to determine a solar system cost from inputs

After a user has entered information about the postcode and solar system required, Solar App will return a cost for the system after rebates.

The cost of the system is made up of the following components.

### Cost of the solar panels including installation

A JSON file will contain eight different system costs based on the quality input value (value for money or premium), and the size input value (6.6kW, 10kW, 15kW, 20kW)

### A rebate amount, based on small-scale technology certificates (STCs)

Per https://www.solargain.com.au/blog/everything-you-need-know-about-stcs STCs are calculated based on megawatt hours of renewable energy generated.

As more energy is generated in Cairns when compared to Hobart, Australia has different Zones for determining the number of STCs that can be claimed.

The following file will be converted into JSON and used by the app, in conjunction with system size and the years left until 2031 when the scheme ends to determine the rebate: http://www.cleanenergyregulator.gov.au/DocumentAssets/Pages/Postcode-zone-ratings-and-postcode-zones-for-solar-panel-systems.aspx

Example rebate: A 10kW system in postcode 4000 installed in 2020

10 * 1.382 * (2031-2021) = 138 STCs

$40 per STC, so 138 * $40 = $5520 rebate 

## 3. Ability to determine a households energy costs from inputs

Solar App will allow users to enter their current monthly power bill if that's available, but will also allow users just to enter the number of adults in their household for Solar App to determine a monthly cost based on averages.

To determine the average cost based on household size and state, the following data will be utilised:

https://www.aer.gov.au/retail-markets/guidelines-reviews/electricity-and-gas-consumption-benchmarks-for-residential-customers-2020 

This Australian Energy Regulator report shows the average consumption of electricity by zone. This will be converted into a JSON file as the AER does not have an API available.

TBA - get price

## 4. Ability to determine the amount of amount of solar credits and usage saving based on the input of a solar system size

TODO - need to add a bit more for the higher quality system, like 5% 

## 5. Ability to determine a return on investment and payback period of a selected solar system size based on inputs

## Optional - a csv time stamped log of all quotes

# R9
Do github projects,etc.

# REFERENCES

Daily kwh per kw installed https://support.solarquotes.com.au/hc/en-us/articles/ 115002395494-What-can-I-expect-my-solar-system-to-produce-on-average-per-day-

Consumption per household 
https://www.lgenergy.com.au/faq/buying-a-solar-system/what-is-the-consumption-in-kwh-for-a-typical-australian-home

Consumption for pool 
https://www.canstarblue.com.au/electricity/how-much-energy-does-a-swimming-pool-use/

Roof orientation: 
https://www.solarquotes.com.au/panels/direction/ 

Average power cost of $0.34 per kWh in Austrlalia
https://electricitywizard.com.au/electricity/electricity-cost/how-much-does-electricity-cost/ 

--- 
CLASS Customer
Name
Email

CLASS Address
Street
City
State

CLASS Solar Quote
System Size
System Cost
Current Power Usage 
Size of household

CLASS Credits
hash of stcs by State
hash of state initiatives 

Class Solar Panels?
---

// Trello board

TODO
json file for 

Use a gem (tty)
Use json fil
Use tty graph 
Use API
