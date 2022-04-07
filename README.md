

# Open EV Data is now part of the Chargeprice API!

After two years of being a separate project, we have decided to integrate Open
EV Data directly into the Chargeprice API.

You can now access the EV data via the [/v2/vehicles
endpoint](https://github.com/chargeprice/chargeprice-api-docs/blob/master/api/v2/vehicles/index.md)
of the [Chargeprice API](https://github.com/chargeprice/chargeprice-api-docs).

[Get access
now!](https://github.com/chargeprice/chargeprice-api-docs#getting-access)

## FAQ

### Why did we integrate Open EV Data into the Chargeprice API?

There are multiple reasons:

1) Initially the idea of Open EV Data was to build an open dataset that everyone
   can use. This was achieved. We were also hoping to get support from the
   community to add new vehicles and keep the data up to date. Unfortunately
   this didn't really work out. So it was mainly (with a few exceptions,
   thanks!) on us, Chargeprice, to manage the data. While we love to do this,
   it's also resource intensive and it's not sustainable for us to provide data
   for free for any - even commercial - projects. In the end we believe that
   only sustainable projects can survive.

2) Technically there has always been some manual effort to get Open EV Data up
   to date with the data that we are already using in Chargeprice. With the
   integration into the Chargeprice API this manual step is now gone.

3) We have played around with multiple data management systems in the past and
   each one resulted in the need to adapt two systems: The Chargeprice API and
   Open EV Data. Now we have a single source of truth and this step is not
   needed anymore.

### What will happen with this repository?

We will keep the `/data/ev-data.json` as it is, because it's anyway accessible
via the Git history and forks. Also we published this data with the MIT Licence
that grants free usage by anyone.

However we won't push any updates anymore.

### Can I still use the data for free?

You can still use the outdated `/data/ev-data.json` data set for free.

If you want to get regular updates, you need to subscribe to our API. You can
find the pricing [here](https://www.chargeprice.net/pricing).

### How do I migrate?

Follow the instructions on the [Chargeprice API
docs](https://github.com/chargeprice/chargeprice-api-docs) to get access to the
data.

Then you need to call our API instead of fetching the file from Github directly.

The data format has slightly changed, but overall it's the same as before. 

### Can I take over the Open EV Data project/idea by fetching the data from your API and publish it here (or anywhere else) for usage by anyone?

No. Thanks for your understanding.

### Are there any benefits for me with the new approach?

Besides making sure that this project can also exist in the future, you will now
also get updates to the dataset much faster! We've usually updated Open EV Data
only on a monthly basis. The data from the Chargeprice API however will be
updated on a weekly or even daily basis!
