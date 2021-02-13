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

## Updating the Data

The data is managed by Chargeprice via the Contentful CMS and is regularly
updated. 

Please file an issue if you have a change request or reach out to
contact@chargeprice.net