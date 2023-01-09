#Camron Miene
#12/05/2022
#cmiene_project
rm(list = ls())
#Install Packages
install.packages('rnoaa')
install.packages('psych')
install.packages('rgl')
install.packages('plotly')
#Load Packages
library(rnoaa)
library(jsonlite)
library(dplyr)
################################################################################
## Package-API ##
## API Token ##
token_noaa<- 'APITokenHERE'

#Initialize ids and filters
datasetid<- 'GSOM'
stationid<- c('GHCND:US1GACE0001','GHCND:US1GAFT0065')

#Set Data range
start_date<- '2020-01-01'
end_date<- '2020-04-01'

## Access data via ncdc() NOAA API
ATL_weather<- ncdc(datasetid = datasetid,
                   stationid = stationid,
                   startdate = start_date,
                   enddate = end_date,
                   token = token_noaa,)
#Check data type
typeof(ATL_weather)

#Convert ATL_weather to data.frame
ATL_weather<- as.data.frame(ATL_weather$data)
## Write to CSV ##
write.csv(ATL_weather, 'cmiene_data2.csv', fileEncoding = 'UTF-8')

#Remove undesired data
ATL_weather<- select(ATL_weather, -fl_a, -fl_M, -fl_Q, -fl_S)

#Create Month column for merge
ATL_weather<- ATL_weather %>%
  mutate(month = row_number())
#Check str
str(ATL_weather)

## Load Airline Delay Data ##
delay<- read.csv('Airline_Delay_Cause.csv', sep = ',',header = TRUE)
#Check str
str(delay)

## Write to CSV ##
write.csv(delay, 'cmiene_data1.csv', fileEncoding = 'UTF-8')

## Sort and Filter delay
#Year = 2020
#Month 1-4
#Atlanta Airport
dat1<- filter(delay, year == 2020& month < 5& airport =='ATL')
dat1<- dat1[order(dat1$month),]
str(dat1)

## Merge by month
dat2<- data.frame()
dat2<- merge(dat1, ATL_weather, by='month')

## Clean and Transform merged data ##
## Remove Columns
#date and station
dat2<- select(dat2, -date, -station)

## Rename Columns
#Precip<-datatype
dat2<- rename(dat2, precip = datatype)
#Precip_in<-value
dat2<- rename(dat2, precip_in = value)

## Write File CSV
write.csv(dat2, 'cmiene_data_merged.csv', fileEncoding = 'UTF-8',)
###################################################################
## Statistical and Plots ##
#Load Packages
library(ggplot2)
library(psych)
library(rgl)
library(plotly)
## Describe data frame ##
stats_df<- describe(dat2)
stats_df<- select(stats_df, -vars, -n, -trimmed)
stats_df<- stats_df[-c(1:6),]
str(stats_df)
write.csv(stats_df, 'cmiene_data_stats.csv', fileEncoding = 'UTF-8')

## Plots
#Create a Barplot "Number of Flights by Airline"
f<-ggplot(dat2, aes(x = carrier_name, y = arr_flights)) + 
  geom_bar(stat = "identity", fill = "blue") +
  xlab("Airline") + 
  ylab("Number of Flights Arrived") +
  ggtitle("Number of Flights by Airline")+
  theme(axis.text.x = element_text(angle=45,hjust =0.75 ))
ggplotly(f)
#Create a scatter plot showing the relationship between the number of 
#flights arrived and the number of delays
#Create scatterplot that's interactive
p<-ggplot(data = dat2, aes(x = arr_flights, y = arr_del15, group = carrier_name)) +
  geom_point(size = 3, shape = 21, color = "darkblue", show.legend = F) +
  geom_smooth(method = "lm", se = F, color = "orange") +
  geom_text(aes(label = paste0("(", arr_flights, ",", arr_del15, ")")), 
            color = "red", check_overlap = T, size = 4) +
  ylab("Delays") +
  xlab("Flights") +
  ggtitle("Flights vs Delays") +
  theme_minimal()
ggplotly(p, tooltip = c('Carrier'))

#Create a plot showing correlation between delays and precipitation
r<-ggplot(data = dat2, 
          aes(x = month, y = arr_del15, fill=precip_in)) +
  geom_bar(stat="identity", position="dodge") +
  ggtitle("Correlation between Arrivals Delayed and Precipitation in by Month") +
  xlab("Month") +
  ylab("Arrivals Delayed") +
  scale_fill_gradient(low="blue", high="red")
ggplotly(r)
