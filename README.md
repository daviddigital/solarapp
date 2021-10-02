# Installation

Download or clone the github code and then run the below script to install the gem dependencies and run the app.

` bash run_app.sh `

# Statement of purpose and scope

## Overview

![Solar app output](./resources/output.jpg "Solar app output")

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


## 5. Ability to determine a return on investment and payback period of a selected solar system size based on inputs

# Control Flow Diagram

![Control Flow Diagram](./resources/solarappv4.png "Control Flow")

# Implementation Plan
A summary of the features and requirements are below, and also on the project kanban board https://github.com/daviddigital/solarapp/projects/1. 
## Feature 1

Summary

Checklist:
- (Priority: High)

# Testing Summary

Each class was run with unit tests covering major features.

## Menu class 

1 test, 1 assertion, 100% passed

## Quote class

12 tests, 12 assertions, 100% passed

## Property class

7 tests, 7 assertions, 100% passed

## Solar System class

6 tests, 6 assertsions, 100% passed 

# References and data sources

Daily kwh per kw installed https://support.solarquotes.com.au/hc/en-us/articles/ 115002395494-What-can-I-expect-my-solar-system-to-produce-on-average-per-day-

Consumption per household 
https://www.lgenergy.com.au/faq/buying-a-solar-system/what-is-the-consumption-in-kwh-for-a-typical-australian-home

Consumption for pool 
https://www.canstarblue.com.au/electricity/how-much-energy-does-a-swimming-pool-use/

Roof orientation: 
https://www.solarquotes.com.au/panels/direction/ 

Average power cost of $0.34 per kWh in Austrlalia
https://electricitywizard.com.au/electricity/electricity-cost/how-much-does-electricity-cost/ 


# Help 

## Installation and Running Solar App

Download or clone the github code and then run the below script to install the gem dependencies and run the app.

` bash run_app.sh `

Add your name or company name as a commmand line argument then running the app to get a personalised welcome message.

e.g. 

` ruby solarapp.rb "David"` 

## Using Solar App and Solar Terminology

Solar App is designed to be as simple as possible. Follow the prompts to find out the costs and benefits of solar.

If you're unsure of what your power cost per kwH, feed in tarrif or system size you're after, just use the defaults which are Australian averages.

A brief description of the questions asked and why they are asked is as follows:

### Postcode

The postcode is used to determine the rebate available to you, and how much power the panels are likely to produce (the two are related). A postzone to zone mapping is used by the app.

As an example, a postcode in sunny Perth will have a higher output than Hobart, and attracts a higher rebate as well as cheaper bills (or more credits).

### Current power cost per kWh

What your current retailer is charging you per kWh, to determine the current solar bill / potential savings after solar installation.

### Houshold size and whether a pool is at the property 

The number of people in the household. This is used, in combination with whether a pool is at the property, to determine an estimated average monthly energy bill, without you needing to look at your last 12 power bills. 

### Main roof orientation

North roofs are best for solar, and South roofs are the worst. 

This factor is used to determine the output of the solar system selected. For example a North roof will produce about 20% more than a South facing roof. 

### Size of system

The size of solar panels. Larger panels will provide a bigger rebate, and more energy savings or feed in tarrifs. 

### Quality of system

The quality of the panels and inverter.

To make things simple we've broken up the categories into "value" and "premium".

Solar App won't produce any increase in output for the premium brands over the value brands. Per a Choice & CSIRO study (https://www.choice.com.au/home-improvement/energy-saving/solar/articles/solar-panel-test-what-we-found), the cheaper Jinko panels from China kept up with the premium brands.

Premium brands may however will provide longer warranties and better service.

### Feed in tarrif

Feed in tarrif is the price per kWh your energy retailer will provide for solar you feed back into the grid.

It should be noted that different states have different rules, and not all of these rules have been built into Solar App.

For example, in QLD only 10kW can be fed into the system on single phase power systems, but three phase power systems can go higher.

Solar App will not impose any limits on amount fed into the grid, so should only be used as an initial desktop study. 

### Installation year 

The STC rebate will end in 2031, and the installation year is used to determine the amount of STCs your system will provide. Each year the STCs will drop, as they are projected out until 2031 from the installation year and claimed upfront by your solar retailer. 

## Overwriting system prices

A system_prices.json has been provided for each combination of system size and quality.

If you'd like to add more options they can be added dirrectly in the .json file. 