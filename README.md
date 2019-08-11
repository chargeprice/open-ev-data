# Open EV Data
Open Dataset of Electric Vehicles and their specs.

In contrast to ICE cars, electric vehicles have very different behavious in terms of charging and charging speed. Hence having reliable data about a car is the key for developing EV-related applications.

This dataset (`data/ev-data.json`) can be freely integrated into ANY application.

This is a side project of the charging price and tariff comparison platform [Chargeprice (former Plugchecker)](https://github.com/hoenic07/plugchecker).

## Available Data

At the moment mostly charging related data is available. Feel free to add more data if you need it!

* ID: Random UUID
* Brand
* Model
* Release Year: Mainly to distinquish models with the same name.
* Variant: Bigger battery, optional faster on-board charger etc.
* Usable Battery Size: in kWh
* AC Charger: Details about the on-board charger.
  * Usable Phases: No. of usable phases for AC charging. Allowed values: 1,2,3
  * Ports: Allowed values: `type1`, `type2`
  * Max Power: in kW
  * Power per Charging Point: Charging power at common charging points. Key and Value in kW.
* DC Charger: `null` if the car doesn't support DC charging
  * Ports: Allowed values: `ccs`, `chademo`, `tesla_suc`, `tesla_ccs`
  * Max Power: in kW
  * Charging Curve: Simplified charging behaviour based on FastNed's charging curve charts. If no charging curve data is available, the default curve is assumed to be: 0%: 95% of max. DC power, 75%: max. DC power, 100%: max. AC power.
    * percentage: Charging level of battery in percentage
    * power: in kW
  * Is Default Charging Curve: `true` if the charging curve is based on the default curve instead of real measured data.

## Updating the Data

### For non-developers (or lazy developers)

Feel free to add change requests via comments to the base dataset: 

https://docs.google.com/spreadsheets/d/1jT9O6YnrRCtY5jjKDL8-3GN5DzCuB64gAi1aL3-I3Ts

### For developers

1. Request write access to: https://docs.google.com/spreadsheets/d/1jT9O6YnrRCtY5jjKDL8-3GN5DzCuB64gAi1aL3-I3Ts/edit (or make a copy)
2. Add your changes
3. Enable the Sheets API in the Google Cloud, [create a Google Cloud Service Account](https://support.google.com/a/answer/7378726?hl=en) and give it access to the spreadsheet
4. Create an `.env` file, based on the `.env.sample` with the credentials of your service account
5. Ensure that Ruby and Bundler (`gem install bundler`) is installed
6. `cd scripts && bundle`
7. Run `ruby update_data.rb` and get the updated `data/ev-data.json` file.