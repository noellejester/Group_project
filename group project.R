```{r}

#| eval: false


library(dplyr)
library(DBI)
library(dbplyr)
library(odbc)

odbcListDrivers()

## connected to the SQL Server Chicago Crime database
con <- DBI::dbConnect(odbc(),
                      Driver = "SQL Server",
                      Server = "mcobsql.business.nd.edu",
                      UID = "MSBAstudent",
                      PWD = "SQL%database!Mendoza",
                      Port = 3306, 
                      Database = "ChicagoCrime")

dbListFields(con, "wards")

dbListFields(con, "crimes")


select_res <- dbFetch(select_q) 

## Find the Streets with the highest crime count

select_q <- dbSendQuery( ## wrote in a SQL Query that counted Crimes on each Street
  conn = con,
  statement = "SELECT block, Count(*) AS 'CrimeCount', longitude, latitude
           FROM crimes
           GROUP BY block, longitude, latitude
           ORDER BY COUNT (*) DESC"
)
select_res <- dbFetch(select_q) 

df1 <- data.frame(select_res)
df_final <- df1 %>% 
  slice_head(n=10) ## sleected the top 10 streets
  

## Create a Heat Map 


library(leaflet)

## creating a Map that shows the counts for each of the top ten streets

leaflet(df_final) %>%
  addTiles() %>%
  addLabelOnlyMarkers(
    lng = ~longitude,
    lat = ~latitude,
    label = ~CrimeCount,
    labelOptions = labelOptions(noHide = TRUE)
  )

df.expanded <- df_final[rep(row.names(df_final), df_final$CrimeCount),]
leaflet(df.expanded) %>% addTiles() %>% 
  addMarkers(clusterOptions = markerClusterOptions())

## creating a heat map 

library(leaflet.extras)
df_final %>% 
  leaflet() %>% 
  addTiles() %>% 
  addHeatmap(lng = df_final$longitude, lat = df_final$latitude,
             blur = 10, max = 0.1, radius = 20)
```




  