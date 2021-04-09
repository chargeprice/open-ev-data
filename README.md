# Open EV Data

Open Dataset of Electric Vehicles and their specs.

In contrast to ICE cars, electric vehicles have very different behavious in
terms of charging and charging speed. Hence having reliable data about a car is
the key for developing EV-related applications.

This dataset (`data/ev-data.json`) can be freely integrated into ANY
application. Mentioning Open EV Data as a source is appreciated!

This is a side project of the charging price and tariff comparison platform
[Chargeprice](https://www.chargeprice.app).

## Available Data

At the moment mostly charging related data is available. Feel free to add more
data if you need it!

* ID: Random UUID
* Brand
* Vehicle Type (car, motorbike)
* Type (BEH, PHEV)
* Model
* Release Year: Mainly to distinquish models with the same name.
* Variant: Bigger battery, optional faster on-board charger etc.
* Usable Battery Size: in kWh
* Average Energy Consumption: in kWh/100km
* AC Charger: Details about the on-board charger.
  * Usable Phases: No. of usable phases for AC charging. Allowed values: 1,2,3
  * Ports: Allowed values: `type1`, `type2`
  * Max Power: in kW
  * Power per Charging Point: Charging power at common charging points. Key and
    Value in kW.
* DC Charger: `null` if the car doesn't support DC charging
  * Ports: Allowed values: `ccs`, `chademo`, `tesla_suc`, `tesla_ccs`
  * Max Power: in kW
  * Charging Curve: Simplified charging behaviour based on various charging
    curve charts (e.g. Fastned). If no charging curve data is available, the
    default curve is assumed to be: 0%: 95% of max. DC power, 75%: max. DC
    power, 100%: max. AC power.
    * percentage: Charging level of battery in percentage
    * power: in kW
  * Is Default Charging Curve: `true` if the charging curve is based on the
    default curve instead of real measured data.

## Change Requests

Please file an issue if you have a change request or reach out to
contact@chargeprice.net

## Contributing

The data is managed by Chargeprice via the Contentful CMS and is regularly
updated. However we are always looking for people who want to contribute to the
project! Feel free to contact contact@chargeprice.net in this case!

## Updating the data

After you have **published** the data on Contentful, Open EV Data needs to get
the changes as well. 

Follow these steps:

### Preconditions

* Have Ruby installed
* Have this project checked out
* Have contentful credentials available and stored in a `scripts/.env` file:

```
CONTENTFUL_ACCESS_TOKEN=<token>
CONTENTFUL_SPACE_ID=<space-id>
 ```

### Running the script

1) `cd scripts`
2) Make sure bundler (`bundle -v`) is installed. If not: `gem install bundler`
3) Install dependencies: `bundle install`
4) `ruby update_data.rb`

Your changes should new appear in `data/ev-data.json`.

### Pushing the changes

1) `git commit -m "ADD charging curve of Aiways U5"` (add a meaningful change
   message)
2) `git push` (push to master is fine)