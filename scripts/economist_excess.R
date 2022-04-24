library(tidyverse)
library(geofacet)
library(ggtext)

source('scripts/theme.R')

colors = c("#8c0900", "#28e6ff", "#ff492a", "#b4b7bd")

df_econ <- read_csv("https://github.com/TheEconomist/covid-19-excess-deaths-tracker/raw/master/output-data/excess-deaths/all_weekly_excess_deaths.csv")

df_econ2 <-
  df_econ%>%
  select(country, start_date, expected_deaths, total_deaths, covid_deaths, population)%>%
  group_by(country)%>%
  mutate(f = ifelse(total_deaths>expected_deaths, "Excess Deaths", "Death 'Deficit'"))%>%
  mutate(min = ifelse(total_deaths<=expected_deaths, total_deaths, expected_deaths))%>%
  mutate(max = ifelse(total_deaths> expected_deaths, total_deaths, expected_deaths))%>%
  mutate(g = ifelse(lag(f)==f, 0, 1))%>%
  mutate(g = ifelse(is.na(g), 0, g))%>%
  mutate(h = cumsum(g))%>%
  rename(State = country,
         `Week Ending Date` = start_date,
         `Observed Number` = total_deaths,
         `Average Expected Count` = expected_deaths,
         `Covid Deaths` = covid_deaths,
         Population = population)


df_sums <-
  df_econ2%>%
  filter(`Week Ending Date`>="2020-03-01" & `Week Ending Date` <="2022-02-01")%>%
  group_by(State)%>%
  summarise(total_deaths = sum(`Observed Number`-`Average Expected Count`),
            total_deaths_per_million = sum((`Observed Number`-`Average Expected Count`)/Population*1000000))%>%
  arrange(desc(total_deaths_per_million))

order_by_deaths <- df_sums$State

df_econ2%>%
  ggplot(aes(x = `Week Ending Date`, y = `Observed Number`/Population*1000000)) +
  scale_y_continuous(limits = c(0, NA)) +
  scale_x_date(date_labels = "´%y", date_breaks = "1 year") +
  coord_cartesian(xlim = as.Date(c("2020-01-01", "2022-01-01")),
                  ylim = c(0, 400), clip = "off") +
  geom_area(aes(fill = "Expected Deaths")) + # "#00000055"
  geom_ribbon(aes(fill = forcats::fct_rev(f),
                  group =  as.character(h),
                  ymin = min/Population*1000000, ymax = max/Population*1000000)) +
  geom_line(aes(linetype = "Observed Number of Deaths")) +
  geom_line(aes(y = `Average Expected Count`/Population*1000000, linetype = "Average Expected Deaths")) +
  geom_label(data = df_sums, aes(label = State), family = font_family, alpha = 0.7,
             x = as.Date("2021-01-01"), y = 400, size = 3.2, vjust = 1) +
  geom_area(aes(y = `Covid Deaths`/Population*1000000, fill = "Covid Deaths")) +
  scale_linetype_manual(values=c(2, 1)) +
  scale_fill_manual(values = colors) + 
  labs(title = "Excess Deaths associated with COVID-19", x = "", y = "",
       subtitle = "Weekly Observed and 'Expected' Deaths from the The Economist, Covid-19 Deaths from Johns Hopkins University | Plot by @bjornpiltz")+
  facet_wrap(~factor(State, levels = order_by_deaths)) +
  theme(legend.position = c(0.8, 0.05),
        strip.text.x = element_blank(),
        legend.box = 'horizontal',
        plot.title=element_text(size = 24),
        plot.subtitle=element_markdown(color = "gray40"))+
  guides(fill = guide_legend(title = "", nrow = 2),
         linetype = guide_legend(title = "", nrow = 2))

gsave(ggplot2::last_plot(), filename = "img/economist_excess_pc_states_geo.png", width = 16, height = 9, dpi = 240)

g <- 
  df_econ2%>%
  ggplot(aes(x = `Week Ending Date`, y = `Observed Number`/Population*1000000)) +
  scale_y_continuous(limits = c(0, NA), , labels = scales::comma) +
  scale_x_date(date_labels = "´%y", date_breaks = "1 year") +
  coord_cartesian(xlim = as.Date(c("2020-01-01", "2022-01-01"))) +
  geom_area(aes(fill = "Expected Deaths")) + 
  geom_ribbon(aes(fill = forcats::fct_rev(f),
                  group =  as.character(h),
                  ymin = min/Population*1000000, ymax = max/Population*1000000)
  ) +
  geom_line(aes(linetype = "Observed Number of Deaths")) +
  geom_line(aes(y = `Average Expected Count`/Population*1000000, linetype = "Average Expected Deaths")) +
  geom_area(aes(y = `Covid Deaths`/Population*1000000, fill = "Covid Deaths")) +
  scale_linetype_manual(values=c(2, 1)) +
  scale_fill_manual(values = colors)

####

west_europe_grid <- read_csv("data/west_eu_grid.csv")

g +   
  labs(subtitle = "<span style='color:#444444;'>
Weekly Observed and 'Expected' Deaths from the Economist</span>",
       title = "Excess Deaths associated with COVID-19", x = "", y = "Weekly Deaths per Million",
       caption = "<span style='color:#444444;'>Plot by @bjornpiltz</span>") +
  geom_label(data = df_econ2%>%group_by(State)%>%summarise(tmp = 1)%>%
               filter(State %in% west_europe_grid$name),
             family = "ETBembo-RomanLF",
             aes(label = State),
             fill = "#FFFFFFAA",
             x = as.Date("2021-01-01"), y = 700, size = 3.2, vjust = 1) +
  facet_geo(~State, grid = west_europe_grid) +
  theme(strip.text.x = element_blank(),
        legend.position = c(0.20, 0.77),      
        legend.box = 'horizontal',
        plot.title=element_text(size = 24),
        plot.subtitle=element_markdown(),
        plot.caption=element_markdown()) +
  guides(fill = guide_legend(title = "", nrow = 2),
         linetype = "none") +
  coord_cartesian(ylim = c(0, 725))

gsave(ggplot2::last_plot(), filename = "img/eu_west_excess_pc_states_geo.png", width = 7, height = 8, dpi = 240)


####

east_europe_grid <- read_csv("data/east_eu_grid.csv")

g +   
  labs(subtitle = "<span style='color:#444444;'>
Weekly Observed and 'Expected' Deaths from the Economist</span>",
       title = "Excess Deaths associated with COVID-19", x = "", y = "Weekly Deaths per Million",
       caption = "<span style='color:#444444;'>Plot by @bjornpiltz</span>") +
  geom_label(data = df_econ2%>%group_by(State)%>%summarise(tmp = 1)%>%
               filter(State %in% east_europe_grid$name),
             family = "ETBembo-RomanLF",
             aes(label = State),
             fill = "#FFFFFFAA",
             x = as.Date("2021-01-01"), y = 700, size = 3.2, vjust = 1) +
  facet_geo(~State, grid = east_europe_grid) +
  theme(strip.text.x = element_blank(),
        legend.position = c(0.20, 0.93),      
        legend.box = 'horizontal',
        plot.title=element_text(size = 24),
        plot.subtitle=element_markdown(),
        #        plot.margin = margin(b=-30, r = 10, l = 15),        
        #        plot.caption.position = c(0,0),
        plot.caption=element_markdown()) +
  guides(fill = guide_legend(title = "", nrow = 2),
         linetype = "none") +
  coord_cartesian(ylim = c(0, 725))

gsave(ggplot2::last_plot(), filename = "img/eu_east_excess_pc_states_geo.png", width = 7, height = 8, dpi = 240)
