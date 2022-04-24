library(tidyverse)
library(geofacet)
library(ggtext)

source("scripts/theme.R")

df <- read_rds("data/us_excess_deaths_per_age_group.rds")

dummy <- 
  df%>%
  group_by(Jurisdiction)%>%
  summarise(Date = as.Date("2021-01-01"))%>%
  filter(!Jurisdiction %in% c("United States", "Puerto Rico"))


g <- df%>%
  spread(Type, `Number of Deaths`)%>%
  group_by(`Age Group`, Jurisdiction)%>%
  arrange(Date)%>%
  mutate(Excess_avg = zoo::rollmean(Observed-Predicted, k = 3, na.pad = T, align  = "center"))%>%
  filter(Year>=2020)%>%
  na.omit()%>%
  filter(Date<"2022-02-01")%>%
  ggplot(aes(x = Date, y = Excess_avg*1000000/Population_all_ages, fill = `Age Group`)) +
  geom_area() +
  theme(legend.position = "top") +  
  scale_x_date(date_labels = "´%y", date_breaks = "1 year") +
  coord_cartesian(xlim = as.Date(c("2020-01-01","2022-02-01")), 
                  ylim = c(0, 200), expand = F, clip = "off") +
  scale_fill_manual(values = c('#999999', '#F1BB7B', '#FD6467', '#5B1A18'))

g + facet_wrap(~Jurisdiction)




g + labs(title = "Excess Deaths associated with COVID-19", 
         subtitle = "<span style='color:#444444;'>
Weekly Observed Deaths from the CDC<br>
Expected Deaths calculated based on Karlinsky & Kobak, 2021</span>",
         x = "", y = "Weekly Deaths per Million",
         caption = "<span style='color:#444444;'>Plot by @bjornpiltz</span>") +
  geom_label(data = dummy,
             family = font_family,
             inherit.aes = FALSE,
             aes(label = Jurisdiction), fill = "white",
             alpha = 0.7,
             x = as.Date("2021-01-01"), y = 192, size = 3.2, vjust = 1) +
  facet_geo(~Jurisdiction) +
theme(strip.text.x = element_blank(),
      legend.position = c(0.92, 0.22),
      plot.title=element_text(margin=margin(t=15, b=-40), size = 24),
      plot.subtitle=element_markdown(margin=margin(t=50, b=-50)),
      plot.margin = margin(b=-30, r = 10, l = 15),        
      plot.caption=element_markdown(margin=margin(t=-21, b = -10)))

gsave(ggplot2::last_plot(), filename = "img/us_excess_age_pc_states_geo.png", width = 16, height = 9, dpi = 240)
    