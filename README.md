# Excess Deaths associated with COVID-19
This repository attempts to collect and visualize different data sources for *Excess Deaths* -- the difference between deaths of all causes in a region and an estimate of *Expected Deaths*. <br>

## CDCs estimates of Excess Deaths for the US
[Excess Deaths Associated with COVID-19](https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm)

By State
<p><a href="img/us_excess_pc_states_geo.png?raw=true"><img src="img/us_excess_pc_states_geo.png" width="800" title="Excess mortality US states"></a></p>

and the whole nation
<p><a href="img/us_excess.png?raw=true"><img src="img/us_excess.png" width="800" title="Excess mortality US states"></a></p>

### By Age group
Unfortunately the CDC doesn't provide estimates of expected deaths by age groups. We have used the method of [Kobak and Karlinsky, 2021](https://github.com/dkobak/excess-mortality/) to calculate an estimate in order to calculate excess deaths by age group.
<p><a href="img/us_excess_age_pc_states_geo.png?raw=true"><img src="img/us_excess_age_pc_states_geo.png" width="800" title="Excess mortality US states"></a></p>

## Comparing select states
<p>The notebook <a href="us_state_comparison.ipynb">us_state_comparison.ipynb</a> shows how the data set can be used to compare mortality of different states.<p/>
<p><a href="img/us_states_comparison.png?raw=true"><img src="img/us_states_comparison.png" width="800" title="Excess mortality US states"></a></p>

## Kobak & Karlinsky
We borrow our baseline *Expeced Deaths* calculation from [Kobak & Karlinsky](https://github.com/dkobak/excess-mortality) using an age dependent linear extrapolation of the 2015–19 trend.  

<p>Here is a visualization of their data as Excess Deaths per Million people. </p>
<p><a href="img/kobak_excess_deaths_pc.png?raw=true"><img src="img/kobak_excess_deaths_pc.png" width="800" title="Excess mortality Kobak & Karlinsky"></a></p>

The same data as a proportion of Expected Deaths.
<p><a href="img/kobak_excess_deaths.png?raw=true"><img src="img/kobak_excess_deaths.png" width="800" title="Excess mortality Kobak & Karlinsky"></a></p>

## The Economist
The Economist has their own [tracker of Excess deaths](https://www.economist.com/graphic-detail/coronavirus-excess-deaths-tracker) with a disparate collection of countries.
<p><a href="img/economist_excess_pc_states_geo.png?raw=true"><img src="img/economist_excess_pc_states_geo.png" width="800" title="Excess mortality Kobak & Karlinsky"></a></p>
<p>Here is a comparison of Excess Deaths in Western and Eastern Europe.</p>

|<p><a href="img/eu_west_excess_pc_states_geo.png?raw=true"><img src="img/eu_west_excess_pc_states_geo.png" width="400" title="Excess mortality in Western Europe"></a></p>   |<p><a href="img/eu_east_excess_pc_states_geo.png?raw=true"><img src="img/eu_east_excess_pc_states_geo.png" width="400" title="Excess mortality in Eastern Europe"></a></p>   |
|---|---|
