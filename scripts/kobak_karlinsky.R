library(tidyverse)
library(geofacet)
library(ggtext)

source('scripts/theme.R')

#colors = c("#8c0900", "#28e6ff", "#ff492a", "#b4b7bd")

df_pop <- read_csv("data/hmd_population.csv")%>%
  merge(
    read_csv("data/hmd_population.csv")%>%
      filter(Age=="DTotal")%>%
      select(-Age)%>%
      rename(Population_total = Population))

df <- read_csv("https://www.mortality.org/Public/STMF/Outputs/stmf.csv", skip=2)%>%
  select(CountryCode, Year, Week, Sex, D0_14, D15_64, D65_74, D75_84, D85p, DTotal)%>%
  gather("Age", "Deaths", -c(CountryCode, Year, Week, Sex))%>%
  merge(df_pop)%>%
  merge(read_csv("https://www.mortality.org/Public/STMF/Outputs/countrynamelist.txt",
                 col_names = c("Country", "CountryCode")))%>%
  merge(read_csv("https://raw.githubusercontent.com/dkobak/excess-mortality/main/baselines-stmf.csv",
                 col_names  = c("CountryCode", "Year", "Age", "Sex", "Week", "Expected Deaths")), all = T)%>%
  mutate(Date = ISOweek::ISOweek2date(paste0(Year, "-W", str_pad(Week, 2, pad = "0"), "-7")))

df2 = 
  df%>%
  filter(!CountryCode %in% c("RUS", "TWN"))%>%
  na.omit()%>%
  group_by(CountryCode, Age, Sex)%>%
  mutate(is_excess = ifelse(`Deaths`>`Expected Deaths`, "Excess Deaths", "Death 'Deficit'"))%>%
  mutate(min = ifelse(`Deaths`<=`Expected Deaths`, `Deaths`, `Expected Deaths`))%>%
  mutate(max = ifelse(`Deaths`> `Expected Deaths`, `Deaths`, `Expected Deaths`))%>%
  mutate(`Mean Expected Deaths` = mean(`Expected Deaths`))%>%
  mutate(group = ifelse(lag(is_excess)==is_excess, 0, 1))%>%
  mutate(group = cumsum(ifelse(is.na(group), 0, group)))

# We'll need this for geom_label()
dummy <- 
  df2%>%
  group_by(Country)%>%
  summarise('Date' = as.Date("2021-01-01"))

df_sums <-
  df2%>%
  filter(Age=="DTotal" & Sex =="b" & Date>="2020-03-01" & Date<="2022-02-01")%>%
  group_by(Country)%>%
  summarise(total_deaths = sum(Deaths-`Expected Deaths`),
            total_deaths_per_million = sum((Deaths-`Expected Deaths`)/Population*1000000))%>%
  arrange(desc(total_deaths_per_million))

order_by_deaths <- df_sums$Country

df2%>%
  filter(Year>=2015 & Age=="DTotal" & Sex=="b")%>%
  ggplot(aes(x = Date, y = Deaths/`Mean Expected Deaths`)) +
  labs(title = "Excess Deaths associated with COVID-19 - estimates by Kobak & Karlinsky",
       x = "", y = "", fill = "") +
  geom_area(aes(fill = "Expected Deaths")) + 
  geom_ribbon(aes(fill = forcats::fct_rev(is_excess),
                  group = group,
                  ymin = min/`Mean Expected Deaths`, 
                  ymax = max/`Mean Expected Deaths`)) +
  geom_line(aes(x = Date, y = Deaths/`Mean Expected Deaths`)) +
  geom_line(aes(x = Date, y = `Expected Deaths`/`Mean Expected Deaths`), linetype =2) +
  geom_label(data = dummy, aes(label = Country), 
             y = 2, alpha = 1, size = 3.2, vjust = 1) +
  scale_x_date(date_labels = "´%y", date_breaks = "1 year") +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent) +
  coord_cartesian(ylim = c(0, 2), clip = "off") +
  facet_wrap(~factor(Country, levels = order_by_deaths)) +
  scale_fill_manual(values = c("#28e6ff", "#ff492a", "#b4b7bd")) +
  theme(strip.text = element_blank(),
        legend.position = "top", legend.box = 'horizontal')
