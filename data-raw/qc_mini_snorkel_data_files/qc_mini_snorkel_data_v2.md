Feather River Mini Snorkel Data QC
================
Maddee Rubenson
August 21, 2024

# Feather River Mini Snorkel Data - 2001 & 2002

## Description of Monitoring Data

A database was provided containing 2001 and 2002 mini snorkel data.

**Timeframe:** March 2001 - August 2002

**Completeness of Record throughout timeframe:** fairly complete

**Sampling Location:** Feather River

**Data Contact:** Ryon Kurth

## Source Database pull

- Database name: `minisnorkdb3.mdb`

Read in data sourced from query script, glimpse raw data and domain
description sheet:

``` r
# read in data to clean 
microhabitat_2002 |> glimpse()
```

    ## Rows: 9,645
    ## Columns: 26
    ## $ MicroHabDataTblID <int> 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, …
    ## $ PDatID            <int> 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, …
    ## $ TCode             <dbl> 0.1, 0.2, 0.3, 0.4, 3.1, 3.2, 3.3, 3.4, 6.1, 6.2, 6.…
    ## $ Depth             <dbl> 17, 19, 11, 12, 11, 10, 8, 9, 10, 19, 19, 37, 16, 14…
    ## $ Velocity          <dbl> 0.22, 0.35, 1.95, 2.14, 1.19, 1.54, 1.26, 1.97, 0.75…
    ## $ Sub1              <int> 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 15,…
    ## $ Sub2              <int> 40, 50, 25, 0, 70, 30, 0, 0, 0, 60, 30, 65, 80, 0, 0…
    ## $ Sub3              <int> 20, 40, 75, 80, 30, 50, 60, 70, 40, 30, 50, 25, 20, …
    ## $ Sub4              <int> 30, 10, 0, 20, 0, 20, 40, 30, 20, 10, 20, 10, 0, 15,…
    ## $ Sub5              <int> 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ Sub6              <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
    ## $ IcovA             <int> 75, 100, 100, 100, 10, 100, 100, 100, 50, 100, 100, …
    ## $ IcovB             <int> 15, 0, 0, 0, 20, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, …
    ## $ IcovC             <int> 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
    ## $ IcovE             <int> 10, 0, 0, 0, 30, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0…
    ## $ IcovF             <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, …
    ## $ Ocov0             <int> 100, 100, 100, 100, 100, 100, 100, 100, 75, 100, 100…
    ## $ Ocov1             <int> 0, 0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 50, 0, 0, 0, 0,…
    ## $ Ocov2             <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
    ## $ SurTurb           <int> 20, 30, 30, 30, 10, 10, 10, 10, 0, 10, 20, 30, 0, 0,…
    ## $ CGU               <chr> "g", "g", "g", "g", "gm", "g", "g", "g", "gm", "gm",…
    ## $ SubSum            <int> 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 10…
    ## $ ICovSum           <int> 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 10…
    ## $ OCovSum           <int> 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 10…
    ## $ VelClicks         <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ AdjVel            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …

## Data transformations

### first table reviewed is the All Fish Observation Table

All of the substrate and cover lookups are not true look ups. Substrate
and cover column indicate a percentage of cover or substrate of each
type. I updated the column names to reflect this and utilized the lookup
tables to understand which substrate or cover type each column was
referring to.

Columns removed:

- SpecAge removed - just a combination of species and age

- i_cov_sum - removed because sum of other columns

- o_cov_sum - removed because sum of other columns

- sub_sum - removed because sum of other columns

- start_time - just a date that seemed wrong

- end_time - also just a date that seemed wrong

- crew - specific crew names do not need to be present on public EDI
  dataset

``` r
# Combine the data here
# 2001/2002 data
all_fish_data <- microhabitat_2002 |> 
  left_join(fish_data_2002, by = c("TCode" = "TCode", "PDatID" = "PDatID")) |> 
  left_join(species_code_lookup_2002, by = c("Species" = "SpeciesCodeID")) |> # all codes are in the lookup
  select(-c(SpeciesCode, Species)) |>
  rename(species = Species.y, 
         percent_fine_substrate = Sub1, 
         percent_sand_substrate = Sub2, 
         percent_small_gravel_substrate = Sub3, 
         percent_large_gravel_substrate = Sub4, 
         percent_cobble_substrate = Sub5, 
         percent_boulder_substrate = Sub6,
         percent_no_cover_inchannel = IcovA, 
         percent_small_woody_cover_inchannel = IcovB, 
         percent_large_woody_cover_inchannel = IcovC, 
         percent_submerged_aquatic_veg_inchannel = IcovE, 
         percent_undercut_bank = IcovF,
         percent_no_cover_overhead = Ocov0,
         percent_cover_half_meter_overhead = Ocov1, 
         percent_cover_more_than_half_meter_overhead = Ocov2)|> 
  # Clean in separate file
  left_join(location_table_2002, by = c("PDatID" = "PhysDataTblID")) |> 
  left_join(weather_code_lookup_2002, by = c("Weather" = "WeatherCodeLookUpID")) |> # all codes are in the lookup
  select(-WeatherCode, -Weather) |> 
  rename(weather = Weather.y) |> 
  # note that there are 0 channel types which do not map to the lookup
  left_join(channel_lookup_2002, by = c("ChannelType" = "ChannelTypeCode")) |> 
  select(-ChannelType, -ChannelTypeCodeID) |> 
  rename(channel_type = ChannelType.y) |> 
  janitor::clean_names() |> 
  # fixes issues with the codes so the CGU lookup will work
  mutate(cgu = tolower(cgu),
         cgu = case_when(cgu == "rm`" ~ "rm",
                         cgu == "gm." ~ "gm",
                         cgu == "" ~ NA,
                         T ~ cgu)) |> 
  left_join(cgu_code_lookup_2002 |> mutate(CGUCode = tolower(CGUCode)), by = c("cgu" = "CGUCode")) |> 
  select(-cgu, -CGUCodeID, -sub_sum, -i_cov_sum, -o_cov_sum, -start_time, -end_time, -crew) |> 
  rename(channel_geomorphic_unit = CGU) |> 
  filter(!is.na(date)) |> 
  write_csv('2002_fish_obs_tmp.csv') # annoying workaround to remove labeled date column 

all_fish_data <- read_csv('2002_fish_obs_tmp.csv')  |> glimpse()
```

    ## Rows: 9827 Columns: 52
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr   (6): species, location, gps_coordinate, weather, channel_type, channel...
    ## dbl  (45): micro_hab_data_tbl_id, p_dat_id, t_code, depth, velocity, percent...
    ## date  (1): date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

    ## Rows: 9,827
    ## Columns: 52
    ## $ micro_hab_data_tbl_id                       <dbl> 18, 18, 18, 19, 20, 21, 22…
    ## $ p_dat_id                                    <dbl> 11, 11, 11, 11, 11, 11, 11…
    ## $ t_code                                      <dbl> 0.1, 0.1, 0.1, 0.2, 0.3, 0…
    ## $ depth                                       <dbl> 17, 17, 17, 19, 11, 12, 11…
    ## $ velocity                                    <dbl> 0.22, 0.22, 0.22, 0.35, 1.…
    ## $ percent_fine_substrate                      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ percent_sand_substrate                      <dbl> 40, 40, 40, 50, 25, 0, 70,…
    ## $ percent_small_gravel_substrate              <dbl> 20, 20, 20, 40, 75, 80, 30…
    ## $ percent_large_gravel_substrate              <dbl> 30, 30, 30, 10, 0, 20, 0, …
    ## $ percent_cobble_substrate                    <dbl> 10, 10, 10, 0, 0, 0, 0, 0,…
    ## $ percent_boulder_substrate                   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ percent_no_cover_inchannel                  <dbl> 75, 75, 75, 100, 100, 100,…
    ## $ percent_small_woody_cover_inchannel         <dbl> 15, 15, 15, 0, 0, 0, 20, 0…
    ## $ percent_large_woody_cover_inchannel         <dbl> 0, 0, 0, 0, 0, 0, 40, 0, 0…
    ## $ percent_submerged_aquatic_veg_inchannel     <dbl> 10, 10, 10, 0, 0, 0, 30, 0…
    ## $ percent_undercut_bank                       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ percent_no_cover_overhead                   <dbl> 100, 100, 100, 100, 100, 1…
    ## $ percent_cover_half_meter_overhead           <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ percent_cover_more_than_half_meter_overhead <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    ## $ sur_turb                                    <dbl> 20, 20, 20, 30, 30, 30, 10…
    ## $ vel_clicks                                  <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ adj_vel                                     <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ fish_data_id                                <dbl> 21, 22, 23, NA, NA, NA, 25…
    ## $ count                                       <dbl> 2, 3, 1, NA, NA, NA, 3, NA…
    ## $ fl_mm                                       <dbl> 35, 35, 25, NA, NA, NA, 25…
    ## $ water_depth                                 <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ dist_to_bottom                              <dbl> 1.0, 1.5, 1.5, NA, NA, NA,…
    ## $ focal_velocity                              <dbl> 0.94, 0.16, 0.16, NA, NA, …
    ## $ av_vel                                      <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ substrate                                   <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ i_cov_code                                  <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ o_cover_code_id                             <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ x_surf_turb                                 <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ fish_in_tran                                <dbl> 0, 0, 0, NA, NA, NA, 0, NA…
    ## $ focal_clicks                                <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ adj_focal_vel                               <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ av_vel_clicks                               <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ adj_av_vel                                  <dbl> NA, NA, NA, NA, NA, NA, NA…
    ## $ species                                     <chr> "Chinook salmon", "Chinook…
    ## $ location                                    <chr> "hatchery ditch", "hatcher…
    ## $ date                                        <date> 2001-03-14, 2001-03-14, 2…
    ## $ water_temp                                  <dbl> 47, 47, 47, 47, 47, 47, 47…
    ## $ river_mile                                  <dbl> 66.6, 66.6, 66.6, 66.6, 66…
    ## $ flow                                        <dbl> 12, 12, 12, 12, 12, 12, 12…
    ## $ number_of_divers                            <dbl> 3, 3, 3, 3, 3, 3, 3, 3, 3,…
    ## $ reach_length                                <dbl> 25, 25, 25, 25, 25, 25, 25…
    ## $ reach_width                                 <dbl> 4, 4, 4, 4, 4, 4, 4, 4, 4,…
    ## $ channel_width                               <dbl> 7, 7, 7, 7, 7, 7, 7, 7, 7,…
    ## $ gps_coordinate                              <chr> NA, NA, NA, NA, NA, NA, NA…
    ## $ weather                                     <chr> "Direct Sunlight", "Direct…
    ## $ channel_type                                <chr> "Sidechannel", "Sidechanne…
    ## $ channel_geomorphic_unit                     <chr> "Glide", "Glide", "Glide",…

**NA and Unknown Date Values**

There are 0 NA values

## Explore Numeric Variables:

``` r
# Filter clean data to show only numeric variables 
all_fish_data %>% select_if(is.numeric) %>% colnames()
```

    ##  [1] "micro_hab_data_tbl_id"                      
    ##  [2] "p_dat_id"                                   
    ##  [3] "t_code"                                     
    ##  [4] "depth"                                      
    ##  [5] "velocity"                                   
    ##  [6] "percent_fine_substrate"                     
    ##  [7] "percent_sand_substrate"                     
    ##  [8] "percent_small_gravel_substrate"             
    ##  [9] "percent_large_gravel_substrate"             
    ## [10] "percent_cobble_substrate"                   
    ## [11] "percent_boulder_substrate"                  
    ## [12] "percent_no_cover_inchannel"                 
    ## [13] "percent_small_woody_cover_inchannel"        
    ## [14] "percent_large_woody_cover_inchannel"        
    ## [15] "percent_submerged_aquatic_veg_inchannel"    
    ## [16] "percent_undercut_bank"                      
    ## [17] "percent_no_cover_overhead"                  
    ## [18] "percent_cover_half_meter_overhead"          
    ## [19] "percent_cover_more_than_half_meter_overhead"
    ## [20] "sur_turb"                                   
    ## [21] "vel_clicks"                                 
    ## [22] "adj_vel"                                    
    ## [23] "fish_data_id"                               
    ## [24] "count"                                      
    ## [25] "fl_mm"                                      
    ## [26] "water_depth"                                
    ## [27] "dist_to_bottom"                             
    ## [28] "focal_velocity"                             
    ## [29] "av_vel"                                     
    ## [30] "substrate"                                  
    ## [31] "i_cov_code"                                 
    ## [32] "o_cover_code_id"                            
    ## [33] "x_surf_turb"                                
    ## [34] "fish_in_tran"                               
    ## [35] "focal_clicks"                               
    ## [36] "adj_focal_vel"                              
    ## [37] "av_vel_clicks"                              
    ## [38] "adj_av_vel"                                 
    ## [39] "water_temp"                                 
    ## [40] "river_mile"                                 
    ## [41] "flow"                                       
    ## [42] "number_of_divers"                           
    ## [43] "reach_length"                               
    ## [44] "reach_width"                                
    ## [45] "channel_width"

### Variable: `count`

**Plotting Count over Period of Record**

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data %>% 
  ggplot(aes(x = rm, y = count, group = 1))+
  # geom_line()+
  geom_point(aes(x=date, y = count))+
  theme_minimal()+
  labs(title = "Count over Time",
       y = "Number of Fish Observations")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

**Numeric Summary of Count over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$count)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    1.00    1.00    3.00   38.74   20.00 1500.00    9207

**NA and Unknown Values**

There are 9207 NA values

### Variable: `date`

**Plotting Date over Period of Record**

All observations are from 2001

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data %>% 
  ggplot(aes(x = date, y = TRUE, group = 1))+
  # geom_line()+
  geom_point(aes(x=date, y = TRUE))+
  theme_minimal()+
  labs(title = "Dates Surveyed",
       y = "")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

**Numeric Summary of Count over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$date)
```

    ##         Min.      1st Qu.       Median         Mean      3rd Qu.         Max. 
    ## "2001-03-13" "2001-06-11" "2001-08-22" "2001-11-26" "2002-05-28" "2002-08-20"

**NA and Unknown Values**

There are 0 NA values

### Variable: \`river_mile\`\`

**Plotting river_mile over Period of Record**

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data %>% 
  ggplot(aes(x = river_mile, y = date, group = 1))+
  # geom_line()+
  geom_point(aes(x=river_mile, y = date))+
  theme_minimal()+
  labs(title = "Dates that River miles Surveyed",
       y = "")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

**Numeric Summary of river_mile over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$river_mile)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00   54.50   59.50   55.87   62.00   66.90

**NA and Unknown Values**

There are 0 NA values

### Variable: `fl_mm`

**Plotting fl_mm over Period of Record**

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = fl_mm)) + 
  geom_histogram(breaks=seq(0, 200, by=2)) + 
  scale_x_continuous(breaks=seq(0, 200, by=25)) +
  theme_minimal() +
  labs(title = "Fork length distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

``` r
all_fish_data %>% 
  mutate(year = as.factor(year(date))) %>%
  ggplot(aes(x = fl_mm, y = species)) + 
  geom_boxplot() + 
  theme_minimal() +
  labs(title = "Fork length summarized by species") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

**Numeric Summary of fl_mm over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$fl_mm)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##   20.00   30.00   40.00   50.59   50.00 1000.00    9207

**NA and Unknown Values**

There are 9207 NA values

### Variable: `dist_to_bottom`

**Plotting dist_to_bottom distribution**

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = dist_to_bottom)) + 
  geom_histogram(breaks=seq(0, 200, by=2)) + 
  scale_x_continuous(breaks=seq(0, 200, by=25)) +
  theme_minimal() +
  labs(title = "Distance to Bottom") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

``` r
all_fish_data %>% 
  mutate(year = as.factor(year(date))) %>%
  ggplot(aes(x = dist_to_bottom, y = as.factor(river_mile))) + 
  geom_boxplot() + 
  theme_minimal() +
  labs(title = "Distance to bottom summarized by river_mile") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

**Numeric Summary of dist_to_bottom over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$river_mile)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00   54.50   59.50   55.87   62.00   66.90

**NA and Unknown Values**

There are 0 NA values

### Variable: `focal_velocity` & `velocity`

**Plotting velocities over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = focal_velocity)) + 
  geom_histogram(breaks=seq(0, 10, by=1), group = "Focal velocity", fill = "blue", alpha = .2 ) + 
  geom_histogram(aes(x = velocity), breaks=seq(0, 10, by=1), group = "Focal velocity", fill = "red", alpha = .2 ) + 
  scale_x_continuous(breaks=seq(0, 10, by=1)) +
  theme_minimal() +
  labs(title = "Focal Velocity vs ") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

Looks like velocity and focal velocity have similar distributions

**Numeric Summary of focal_velocity over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$focal_velocity)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##   0.000   0.000   0.000   0.355   0.580   3.440    9219

``` r
summary(all_fish_data$velocity)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##  0.0000  0.0000  0.0000  0.4840  0.7925  5.7300     435

**NA and Unknown Values**

There are 9219 NA values There are 435 NA values

### Variable: `t_code`

**Plotting t_code over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = t_code)) + 
  geom_histogram(breaks=seq(0, 30, by=1)) + 
  scale_x_continuous(breaks=seq(0, 30, by=1)) +
  theme_minimal() +
  labs(title = "T code distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

**Numeric Summary of t_code over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$t_code)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.10    6.20   12.20   12.27   18.35   24.40

**NA and Unknown Values**

There are 0 NA values

### Variable: `depth`

**Plotting depth over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = depth)) + 
  geom_histogram(breaks=seq(0, 250, by=1)) + 
  scale_x_continuous(breaks=seq(0, 200, by=50)) +
  theme_minimal() +
  labs(title = "T code distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->

**Numeric Summary of depth over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$depth)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    0.00    0.25    5.00   15.95   26.00  316.00       1

**NA and Unknown Values**

There are 0 NA values

### Variable: `substrate`

**Plotting substrate over Period of Record**

``` r
# Make whatever plot is appropriate 
# maybe 2+ plots are appropriate
all_fish_data |> 
  arrange(river_mile) |> 
  mutate(obs_id = 1:nrow(all_fish_data)) |> 
  select(obs_id, 
         percent_fine_substrate,
         percent_sand_substrate,
         percent_small_gravel_substrate,
         percent_large_gravel_substrate,
         percent_cobble_substrate,
         percent_boulder_substrate) |> 
  pivot_longer(cols = percent_fine_substrate:percent_boulder_substrate, 
               names_to = "substrate_type", values_to = "percent") |> 
  ggplot(aes(x = obs_id, y = percent, fill = substrate_type)) +
  geom_col() +
  scale_fill_manual(values = colors_small) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-23-1.png)<!-- -->

**Numeric Summary of substrate over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$percent_fine_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.000   0.000   5.135   0.000 100.000

``` r
summary(all_fish_data$percent_sand_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00    0.00    0.00   16.49   20.00  100.00

``` r
summary(all_fish_data$percent_small_gravel_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00    0.00   20.00   31.51   50.00  100.00

``` r
summary(all_fish_data$percent_large_gravel_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00    0.00   25.00   32.19   50.00  100.00

``` r
summary(all_fish_data$percent_boulder_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##   0.000   0.000   0.000   2.516   0.000 100.000       1

``` r
summary(all_fish_data$percent_cobble_substrate)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    0.00    0.00    0.00   12.18   20.00  100.00       1

**NA and Unknown Values**

There are 0 NA values There are 0 NA values There are 0 NA values There
are 0 NA values There are 1 NA values There are 1 NA values

### Variable: `inchannel cover`

**Plotting inchannel cover over Period of Record**

Notes: - some cover totals less than 100%

``` r
all_fish_data |> 
  arrange(river_mile) |> 
  mutate(obs_id = 1:nrow(all_fish_data)) |> 
  select(obs_id, 
         percent_no_cover_inchannel,
         percent_small_woody_cover_inchannel,
         percent_large_woody_cover_inchannel,
         percent_submerged_aquatic_veg_inchannel) |> 
  pivot_longer(cols = percent_no_cover_inchannel:percent_submerged_aquatic_veg_inchannel, 
               names_to = "inchannel_cover_type", values_to = "percent") |> 
  ggplot(aes(x = obs_id, y = percent, fill = inchannel_cover_type)) +
  geom_col() +
  scale_fill_manual(values = colors_small[4:7]) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

**Numeric Summary of inchannel cover over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$percent_no_cover_inchannel)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00   70.00   90.00   81.41  100.00  100.00

``` r
summary(all_fish_data$percent_small_woody_cover_inchannel)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.000   0.000   3.823   0.000 100.000

``` r
summary(all_fish_data$percent_large_woody_cover_inchannel)
```

    ##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
    ##   0.0000   0.0000   0.0000   0.2916   0.0000 100.0000        2

``` r
summary(all_fish_data$percent_submerged_aquatic_veg_inchannel)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00    0.00    0.00   14.19   20.00  100.00

**NA and Unknown Values**

There are 0 NA values There are 0 NA values There are 2 NA values There
are 0 NA values

### Variable: `overhead cover`

**Plotting overhead cover over Period of Record**

Notes: - some cover totals more than 100%

``` r
all_fish_data |> 
  arrange(river_mile) |> 
  mutate(obs_id = 1:nrow(all_fish_data)) |> 
  select(obs_id, 
         percent_undercut_bank,
         percent_no_cover_overhead,
         percent_cover_half_meter_overhead,
         percent_cover_more_than_half_meter_overhead) |> 
  pivot_longer(cols = percent_undercut_bank:percent_cover_more_than_half_meter_overhead, 
               names_to = "overhead_cover_type", values_to = "percent") |> 
  ggplot(aes(x = obs_id, y = percent, fill = overhead_cover_type)) +
  geom_col() +
  scale_fill_manual(values = colors_small[4:7]) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-27-1.png)<!-- -->

**Numeric Summary of overhead cover over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$percent_undercut_bank)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.0000  0.0000  0.0000  0.2814  0.0000 75.0000

``` r
summary(all_fish_data$percent_no_cover_overhead)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##     0.0    90.0   100.0    88.8   100.0   100.0

``` r
summary(all_fish_data$percent_cover_half_meter_overhead)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.000   0.000   6.788   0.000 100.000

``` r
summary(all_fish_data$percent_cover_more_than_half_meter_overhead)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.000   0.000   4.414   0.000 100.000

**NA and Unknown Values**

There are 0 NA values There are 0 NA values There are 0 NA values There
are 0 NA values

### Variable: `sur_turb`

**Plotting sur_turb over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = sur_turb)) + 
  geom_histogram(breaks=seq(0, 75, by=1)) + 
  scale_x_continuous(breaks=seq(0, 75, by=5)) +
  theme_minimal() +
  labs(title = "Surface turbidity distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

**Numeric Summary of sur_turb over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$sur_turb)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##   0.000   0.000   0.000   4.677   0.000 100.000     108

**NA and Unknown Values**

There are 108 NA values

### Variable: `dist_to_bottom`

**Plotting dist_to_bottom over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = dist_to_bottom)) + 
  geom_histogram(breaks=seq(0, 5, by=1)) + 
  scale_x_continuous(breaks=seq(0, 5, by=1)) +
  theme_minimal() +
  labs(title = "Distance") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

**Numeric Summary of dist_to_bottom over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$dist_to_bottom)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##   0.000   0.080   1.000   6.961   8.000 110.000    9207

**NA and Unknown Values**

There are 9207 NA values

### Variable: `fish_data_id`

Looks like there are one more unique fish data id than there is number
of rows where joined fish has a count greater than o

``` r
nrow(all_fish_data |> filter(count > 0)) == length(unique(all_fish_data$fish_data_id))
```

    ## [1] FALSE

**Numeric Summary of fish_data_id over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$fish_data_id)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    11.0   167.8   338.5   340.1   511.2   690.0    9207

**NA and Unknown Values**

There are 9207 NA values

### Variable: `micro_hab_data_tbl_id`

There are more observations than unique micro hab ids so there are some
micro habitat transects that have more than one row in the table

``` r
nrow(all_fish_data) == length(unique(all_fish_data$micro_hab_data_tbl_id))
```

    ## [1] FALSE

**Numeric Summary of micro_hab_data_tbl_id over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$micro_hab_data_tbl_id)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##      18    2412    4802    4890    7348    9981

**NA and Unknown Values**

There are 0 NA values

### Variable: `water_temp`

**Plotting water_temp over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = water_temp)) + 
  geom_histogram(breaks=seq(0, 90, by=1)) + 
  scale_x_continuous(breaks=seq(0, 90, by=5)) +
  theme_minimal() +
  labs(title = "Temperature distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-37-1.png)<!-- -->

**Numeric Summary of water_temp over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$water_temp)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    0.00   53.50   59.00   54.39   66.00   85.00     259

**NA and Unknown Values**

There are 259 NA values

### Variable: `flow`

**Plotting flow over Period of Record**

``` r
all_fish_data |> 
  # filter(fork_length < 250) %>% # filter out 13 points so we can more clearly see distribution
  ggplot(aes(x = flow)) + 
  geom_histogram(breaks=seq(0, 3500, by=50)) + 
  scale_x_continuous(breaks=seq(0, 3500, by=1000)) +
  theme_minimal() +
  labs(title = "Flow distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-39-1.png)<!-- -->

**Numeric Summary of flow over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$flow)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##       0     600     650    1214    1750    6100     144

**NA and Unknown Values**

There are 144 NA values

### Variable: `number_of_divers`

**Plotting number_of_divers over Period of Record**

``` r
all_fish_data |> 
  ggplot(aes(x = number_of_divers)) + 
  geom_histogram(breaks=seq(0, 6, by=1)) + 
  scale_x_continuous(breaks=seq(0, 6, by=1)) +
  theme_minimal() +
  labs(title = "Number of Divers distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-41-1.png)<!-- -->

**Numeric Summary of number_of_divers over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$number_of_divers)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   2.000   2.000   2.071   2.000   4.000

**NA and Unknown Values**

There are 0 NA values

### Variable: `reach_length`

All of the reach lengths are 25 (m?)

**Plotting reach_length over Period of Record**

``` r
all_fish_data |> 
  ggplot(aes(x = reach_length)) + 
  geom_histogram(breaks=seq(0, 100, by=1)) + 
  scale_x_continuous(breaks=seq(0, 100, by=25)) +
  theme_minimal() +
  labs(title = "Reach Length distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-43-1.png)<!-- -->

**Numeric Summary of reach_length over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$reach_length)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##      25      25      25      25      25      25

**NA and Unknown Values**

There are 0 NA values

### Variable: `reach_width`

All of the reach widths are 4 meters

**Plotting reach_width over Period of Record**

``` r
all_fish_data |> 
  ggplot(aes(x = reach_width)) + 
  geom_histogram(breaks=seq(0, 10, by=1)) + 
  scale_x_continuous(breaks=seq(0, 10, by=1)) +
  theme_minimal() +
  labs(title = "Reach Width distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-45-1.png)<!-- -->

**Numeric Summary of reach_width over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$reach_width)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##       4       4       4       4       4       4

**NA and Unknown Values**

There are 0 NA values

### Variable: `chanel_width`

**Plotting chanel_width over Period of Record**

Even through reach width measured is only ever 4 meters sometimes
channel width is much larger

``` r
all_fish_data |> 
  ggplot(aes(x = channel_width)) + 
  geom_histogram(breaks=seq(0, 170, by=1)) + 
  scale_x_continuous(breaks=seq(0, 170, by=50)) +
  theme_minimal() +
  labs(title = "Channel Width distribution") + 
  theme(text = element_text(size = 18),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
```

![](qc_mini_snorkel_data_v2_files/figure-gfm/unnamed-chunk-47-1.png)<!-- -->

**Numeric Summary of chanel_width over Period of Record**

``` r
# Table with summary statistics
summary(all_fish_data$channel_width)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##    0.00   20.00   37.00   39.29   53.00  160.00     219

**NA and Unknown Values**

There are 0 NA values

## Explore Categorical variables:

``` r
# Filter clean data to show only categorical variables 
all_fish_data %>% select_if(is.character) %>% colnames()
```

    ## [1] "species"                 "location"               
    ## [3] "gps_coordinate"          "weather"                
    ## [5] "channel_type"            "channel_geomorphic_unit"

### Variable: `location`

``` r
table(all_fish_data$location) 
```

    ## 
    ##   Across Big Hole Island ( River Right)                    Across from Big Hole 
    ##                                      38                                      36 
    ##          Across From Big Hole Boat Ramp                             Alec Riffle 
    ##                                      36                                      36 
    ##                                Aleck #1                            Aleck Riffle 
    ##                                      72                                     184 
    ##                         Aleck Riffle #2                     Aleck Riffle Sect 3 
    ##                                      36                                      36 
    ##                              Auditorium                       Auditorium Riffle 
    ##                                     159                                     192 
    ##                            Auditorium#3                                 Bedrock 
    ##                                      37                                      76 
    ##                            Bedrock Park                         Bedrock Park #3 
    ##                                      36                                      36 
    ##                         Bedrock Park #4                  Bedrock Park, Unit #50 
    ##                                      37                                      37 
    ##                          Bedrock Riffle                                 big bar 
    ##                                      72                                      36 
    ##                                 Big Bar     Big Bar - Middle Island River Right 
    ##                                     180                                      36 
    ##                              Big Bar #1                                Big Hole 
    ##                                      72                                      72 
    ##                         Big Hole Island                       Big Hole Lower #2 
    ##                                      36                                      72 
    ##                              Cox Riffle                           cox riffle #3 
    ##                                      36                                      36 
    ##                           Cox Riffle #4                           Cox Riffle #5 
    ##                                      36                                      36 
    ##                    Cox Riffle section 3                               East G 95 
    ##                                      36                                      36 
    ##                                     EYE                                  Eye #2 
    ##                                      36                                      41 
    ##                              Eye Riffle                           Eye Riffle #3 
    ##                                     180                                      36 
    ##                            Eye Riffle 4                 Eye Riffle Main Channel 
    ##                                      36                                      36 
    ##                         Eye Riffle Side                 Eye Riffle Side Channel 
    ##                                      37                                      41 
    ##                   Eye Riffle, Unit #208                             Eye side #2 
    ##                                      36                                      36 
    ##                             Eye Side #2                        Eye Side Channel 
    ##                                      38                                      72 
    ##                     eye side channel #2                                    G 95 
    ##                                      38                                      36 
    ##                                    G-95                        G-95 (section 4) 
    ##                                      72                                      37 
    ##                               G-95 East                            G-95 East #3 
    ##                                      36                                      36 
    ##                       G-95 Side Channel                                     G95 
    ##                                      36                                     144 
    ##                              G95 (Area)                                  G95 #5 
    ##                                      36                                      36 
    ##                                G95 East                             G95 East #1 
    ##                                     109                                      36 
    ##                  g95 rr downstream head                             G95 WEST #4 
    ##                                      37                                      36 
    ##                   G95 West Side Channel                                 Gateway 
    ##                                      36                                      36 
    ##                          Gateway Riffle                       gateway riffle #4 
    ##                                      36                                      37 
    ##                            goose riffle                            Goose Riffle 
    ##                                      36                                     144 
    ##                         Goose Riffle #1                         Goose Section 2 
    ##                                      36                                      36 
    ##                          gridley riffle                          Gridley Riffle 
    ##                                      39                                     144 
    ##         Gridley Riffle (sidechannel) #1                       Gridley Riffle #1 
    ##                                      36                                      36 
    ##                       Gridley Riffle #3                    Gridley Side Channel 
    ##                                      36                                      36 
    ##                          Grifley Riffle                         Hatchery  Ditch 
    ##                                      36                                      42 
    ##                          hatchery ditch                          Hatchery ditch 
    ##                                     100                                      38 
    ##                          Hatchery Ditch                       HATCHERY DITCH #3 
    ##                                     229                                      46 
    ##                         hatchery riffle                         Hatchery riffle 
    ##                                      36                                      80 
    ##                         Hatchery Riffle                      Hatchery riffle #3 
    ##                                     265                                      40 
    ##                               Herringer               Herringer Main Channel #1 
    ##                                      36                                      36 
    ##               herringer main river left                        Herringer Riffle 
    ##                                      36                                     108 
    ##                       Herringer Side #2                                Hour Bar 
    ##                                      36                                     217 
    ##                               Hour Bars                            Hour Bars #1 
    ##                                      36                                      36 
    ##                        hour east riffle                             hour riffle 
    ##                                      36                                      36 
    ##                             Hour Riffle                     Hour riffle (lower) 
    ##                                      36                                      36 
    ##                          Hour Section 2                                Junkyard 
    ##                                      36                                      36 
    ##                         Junkyard Riffle                      Junkyard Riffle #2 
    ##                                     108                                      37 
    ##                      Junkyard Riffle #4               Junkyard riffle section 2 
    ##                                      36                                      36 
    ##                      Junkyard Section 1                          Lower Big Hole 
    ##                                      37                                     144 
    ##                       Lower Big Hole #1                              Lower Hole 
    ##                                      72                                      36 
    ##                              Lower Hour                       Lower Hour Riffle 
    ##                                     108                                      36 
    ##                 Lower Hour Side Channel                          Lower Robinson 
    ##                                      36                                      37 
    ##                              MacFarland                       macfarland riffle 
    ##                                      36                                      36 
    ##                       Macfarland Riffle                              mathews #2 
    ##                                      72                                      36 
    ##                              Mathews #5                          Mathews Riffle 
    ##                                      46                                      72 
    ##                          MATHEWS RIFFLE                       MATHEWS RIFFLE #1 
    ##                                      37                                      36 
    ##                       Mathews Riffle #3                         Matthews Riffle 
    ##                                      36                                      36 
    ##                               McFarland                            McFarland #1 
    ##                                      36                                      36 
    ##                        McFarland Riffle                       McFarland Riffle` 
    ##                                      36                                      36 
    ##      River Right Below Vance Ave Bridge                   Robinson Main Channel 
    ##                                      36                                      36 
    ##                         Robinson riffle                         Robinson Riffle 
    ##                                      36                                     109 
    ##                      Robinson Riffle #2                      robinson riffle #4 
    ##                                      36                                      37 
    ##                      Robinson Riffle #4                        Robinson side #2 
    ##                                      73                                      72 
    ##                        Robinson side #4                   Robinson Side Channel 
    ##                                      36                                     144 
    ##                   ROBINSON SIDE CHANNEL                Robinson Side channel #1 
    ##                                      36                                      36 
    ##                Robinson Side Channel #3                       Robinsoon Main #2 
    ##                                      36                                      36 
    ##                                 Shallow                  Shallow Main Section 1 
    ##                                      36                                      37 
    ##                          shallow riffle                          Shallow Riffle 
    ##                                      43                                      72 
    ##                   Shallow Riffle (Main)                       Shallow Riffle #3 
    ##                                      36                                      36 
    ##         Shallow Riffle 3 (side channel)                Shallow Riffle Section 2 
    ##                                      36                                      36 
    ##                     Shallow Riffle Side                  shallow riffle west #3 
    ##                                      36                                      36 
    ##                         Shallow Side #1                           Steep Main #1 
    ##                                      36                                      36 
    ##                           Steep Main #2                      Steep main channel 
    ##                                      36                                      36 
    ##                            Steep Riffle                         Steep Riffle #2 
    ##                                     217                                      36 
    ##                         Steep Riffle #3                           steep side #2 
    ##                                      36                                      38 
    ##                           Steep side #3                      Steep side channel 
    ##                                      36                                      39 
    ##                      Steep Side Channel                   steep side channel #3 
    ##                                     111                                      36 
    ##                       Steep Side Riffle                    Steep Side Riffle #2 
    ##                                      36                                      36 
    ##                            Trailer Park                            TRAILER PARK 
    ##                                      72                                      35 
    ##                         Trailer Park #1                  Trailer Park riffl e#4 
    ##                                      36                                      36 
    ##                     Trailer Park Riffle                  Trailer Park, Unit #98 
    ##                                      72                                      37 
    ##                         Trialer park #3                          Upper Big hole 
    ##                                      36                                      36 
    ##                          Upper Big Hole Vance (300 yards below-RR-right channel 
    ##                                      72                                      36 
    ##                                Vance #5                               Vance Ave 
    ##                                      36                                      36 
    ##                            Vance Ave #5                           Vance Ave. #1 
    ##                                      36                                      36 
    ##                            Vance Avenue            Vance Avenue BL - River Left 
    ##                                      36                                      36 
    ##                           Vance East #6                                    Weir 
    ##                                      34                                      36 
    ##                                 weir #2                           Weir Rffle #1 
    ##                                      36                                      36 
    ##                             Weir Riffle                          Weir riffle #2 
    ##                                      72                                      36 
    ##                          weir section 1 
    ##                                      36

Fix inconsistencies with spelling, capitalization, and abbreviations.

``` r
# Fix any inconsistencies with categorical variables
all_fish_data$location <- tolower(all_fish_data$location)
table(all_fish_data$location) 
```

    ## 
    ##   across big hole island ( river right)                    across from big hole 
    ##                                      38                                      36 
    ##          across from big hole boat ramp                             alec riffle 
    ##                                      36                                      36 
    ##                                aleck #1                            aleck riffle 
    ##                                      72                                     184 
    ##                         aleck riffle #2                     aleck riffle sect 3 
    ##                                      36                                      36 
    ##                              auditorium                       auditorium riffle 
    ##                                     159                                     192 
    ##                            auditorium#3                                 bedrock 
    ##                                      37                                      76 
    ##                            bedrock park                         bedrock park #3 
    ##                                      36                                      36 
    ##                         bedrock park #4                  bedrock park, unit #50 
    ##                                      37                                      37 
    ##                          bedrock riffle                                 big bar 
    ##                                      72                                     216 
    ##     big bar - middle island river right                              big bar #1 
    ##                                      36                                      72 
    ##                                big hole                         big hole island 
    ##                                      72                                      36 
    ##                       big hole lower #2                              cox riffle 
    ##                                      72                                      36 
    ##                           cox riffle #3                           cox riffle #4 
    ##                                      36                                      36 
    ##                           cox riffle #5                    cox riffle section 3 
    ##                                      36                                      36 
    ##                               east g 95                                     eye 
    ##                                      36                                      36 
    ##                                  eye #2                              eye riffle 
    ##                                      41                                     180 
    ##                           eye riffle #3                            eye riffle 4 
    ##                                      36                                      36 
    ##                 eye riffle main channel                         eye riffle side 
    ##                                      36                                      37 
    ##                 eye riffle side channel                   eye riffle, unit #208 
    ##                                      41                                      36 
    ##                             eye side #2                        eye side channel 
    ##                                      74                                      72 
    ##                     eye side channel #2                                    g 95 
    ##                                      38                                      36 
    ##                                    g-95                        g-95 (section 4) 
    ##                                      72                                      37 
    ##                               g-95 east                            g-95 east #3 
    ##                                      36                                      36 
    ##                       g-95 side channel                                     g95 
    ##                                      36                                     144 
    ##                              g95 (area)                                  g95 #5 
    ##                                      36                                      36 
    ##                                g95 east                             g95 east #1 
    ##                                     109                                      36 
    ##                  g95 rr downstream head                             g95 west #4 
    ##                                      37                                      36 
    ##                   g95 west side channel                                 gateway 
    ##                                      36                                      36 
    ##                          gateway riffle                       gateway riffle #4 
    ##                                      36                                      37 
    ##                            goose riffle                         goose riffle #1 
    ##                                     180                                      36 
    ##                         goose section 2                          gridley riffle 
    ##                                      36                                     183 
    ##         gridley riffle (sidechannel) #1                       gridley riffle #1 
    ##                                      36                                      36 
    ##                       gridley riffle #3                    gridley side channel 
    ##                                      36                                      36 
    ##                          grifley riffle                         hatchery  ditch 
    ##                                      36                                      42 
    ##                          hatchery ditch                       hatchery ditch #3 
    ##                                     367                                      46 
    ##                         hatchery riffle                      hatchery riffle #3 
    ##                                     381                                      40 
    ##                               herringer               herringer main channel #1 
    ##                                      36                                      36 
    ##               herringer main river left                        herringer riffle 
    ##                                      36                                     108 
    ##                       herringer side #2                                hour bar 
    ##                                      36                                     217 
    ##                               hour bars                            hour bars #1 
    ##                                      36                                      36 
    ##                        hour east riffle                             hour riffle 
    ##                                      36                                      72 
    ##                     hour riffle (lower)                          hour section 2 
    ##                                      36                                      36 
    ##                                junkyard                         junkyard riffle 
    ##                                      36                                     108 
    ##                      junkyard riffle #2                      junkyard riffle #4 
    ##                                      37                                      36 
    ##               junkyard riffle section 2                      junkyard section 1 
    ##                                      36                                      37 
    ##                          lower big hole                       lower big hole #1 
    ##                                     144                                      72 
    ##                              lower hole                              lower hour 
    ##                                      36                                     108 
    ##                       lower hour riffle                 lower hour side channel 
    ##                                      36                                      36 
    ##                          lower robinson                              macfarland 
    ##                                      37                                      36 
    ##                       macfarland riffle                              mathews #2 
    ##                                     108                                      36 
    ##                              mathews #5                          mathews riffle 
    ##                                      46                                     109 
    ##                       mathews riffle #1                       mathews riffle #3 
    ##                                      36                                      36 
    ##                         matthews riffle                               mcfarland 
    ##                                      36                                      36 
    ##                            mcfarland #1                        mcfarland riffle 
    ##                                      36                                      36 
    ##                       mcfarland riffle`      river right below vance ave bridge 
    ##                                      36                                      36 
    ##                   robinson main channel                         robinson riffle 
    ##                                      36                                     145 
    ##                      robinson riffle #2                      robinson riffle #4 
    ##                                      36                                     110 
    ##                        robinson side #2                        robinson side #4 
    ##                                      72                                      36 
    ##                   robinson side channel                robinson side channel #1 
    ##                                     180                                      36 
    ##                robinson side channel #3                       robinsoon main #2 
    ##                                      36                                      36 
    ##                                 shallow                  shallow main section 1 
    ##                                      36                                      37 
    ##                          shallow riffle                   shallow riffle (main) 
    ##                                     115                                      36 
    ##                       shallow riffle #3         shallow riffle 3 (side channel) 
    ##                                      36                                      36 
    ##                shallow riffle section 2                     shallow riffle side 
    ##                                      36                                      36 
    ##                  shallow riffle west #3                         shallow side #1 
    ##                                      36                                      36 
    ##                           steep main #1                           steep main #2 
    ##                                      36                                      36 
    ##                      steep main channel                            steep riffle 
    ##                                      36                                     217 
    ##                         steep riffle #2                         steep riffle #3 
    ##                                      36                                      36 
    ##                           steep side #2                           steep side #3 
    ##                                      38                                      36 
    ##                      steep side channel                   steep side channel #3 
    ##                                     150                                      36 
    ##                       steep side riffle                    steep side riffle #2 
    ##                                      36                                      36 
    ##                            trailer park                         trailer park #1 
    ##                                     107                                      36 
    ##                  trailer park riffl e#4                     trailer park riffle 
    ##                                      36                                      72 
    ##                  trailer park, unit #98                         trialer park #3 
    ##                                      37                                      36 
    ##                          upper big hole vance (300 yards below-rr-right channel 
    ##                                     108                                      36 
    ##                                vance #5                               vance ave 
    ##                                      36                                      36 
    ##                            vance ave #5                           vance ave. #1 
    ##                                      36                                      36 
    ##                            vance avenue            vance avenue bl - river left 
    ##                                      36                                      36 
    ##                           vance east #6                                    weir 
    ##                                      34                                      36 
    ##                                 weir #2                           weir rffle #1 
    ##                                      36                                      36 
    ##                             weir riffle                          weir riffle #2 
    ##                                      72                                      36 
    ##                          weir section 1 
    ##                                      36

``` r
all_fish_data <- all_fish_data |> 
  mutate(location = case_when(location %in% c("aleck riffle", "alec riffle") ~ "aleck riffle",
                              location == "hatchery  ditch" ~ "hatchery ditch",
                              location %in% c("hour bars", "hour bar") ~ "hour bars",
         T ~ location))
unique(all_fish_data$location)
```

    ##   [1] "hatchery ditch"                         
    ##   [2] "hour bars"                              
    ##   [3] "hatchery riffle"                        
    ##   [4] "trailer park riffle"                    
    ##   [5] "bedrock park"                           
    ##   [6] "steep riffle"                           
    ##   [7] "robinson side channel"                  
    ##   [8] "steep side channel"                     
    ##   [9] "robinson riffle"                        
    ##  [10] "upper big hole"                         
    ##  [11] "lower big hole"                         
    ##  [12] "g95"                                    
    ##  [13] "g95 east"                               
    ##  [14] "lower hole"                             
    ##  [15] "gridley riffle"                         
    ##  [16] "big bar"                                
    ##  [17] "goose riffle"                           
    ##  [18] "macfarland riffle"                      
    ##  [19] "shallow"                                
    ##  [20] "herringer"                              
    ##  [21] "junkyard"                               
    ##  [22] "auditorium riffle"                      
    ##  [23] "bedrock riffle"                         
    ##  [24] "eye side channel"                       
    ##  [25] "mathews riffle"                         
    ##  [26] "eye riffle"                             
    ##  [27] "lower hour"                             
    ##  [28] "lower hour side channel"                
    ##  [29] "junkyard riffle"                        
    ##  [30] "shallow riffle"                         
    ##  [31] "trailer park"                           
    ##  [32] "aleck riffle"                           
    ##  [33] "robinson main channel"                  
    ##  [34] "steep side riffle"                      
    ##  [35] "weir riffle"                            
    ##  [36] "vance avenue bl - river left"           
    ##  [37] "big hole island"                        
    ##  [38] "across from big hole boat ramp"         
    ##  [39] "g95 (area)"                             
    ##  [40] "bedrock"                                
    ##  [41] "lower robinson"                         
    ##  [42] "eye riffle main channel"                
    ##  [43] "eye riffle side"                        
    ##  [44] "big hole"                               
    ##  [45] "g95 west side channel"                  
    ##  [46] "hour riffle"                            
    ##  [47] "shallow riffle side"                    
    ##  [48] "herringer riffle"                       
    ##  [49] "g 95"                                   
    ##  [50] "east g 95"                              
    ##  [51] "vance avenue"                           
    ##  [52] "auditorium"                             
    ##  [53] "weir"                                   
    ##  [54] "eye riffle side channel"                
    ##  [55] "vance (300 yards below-rr-right channel"
    ##  [56] "across big hole island ( river right)"  
    ##  [57] "across from big hole"                   
    ##  [58] "g-95 side channel"                      
    ##  [59] "mcfarland riffle`"                      
    ##  [60] "gridley side channel"                   
    ##  [61] "herringer main river left"              
    ##  [62] "g95 rr downstream head"                 
    ##  [63] "bedrock park, unit #50"                 
    ##  [64] "trailer park, unit #98"                 
    ##  [65] "matthews riffle"                        
    ##  [66] "eye riffle, unit #208"                  
    ##  [67] "river right below vance ave bridge"     
    ##  [68] "big bar - middle island river right"    
    ##  [69] "auditorium#3"                           
    ##  [70] "gridley riffle #1"                      
    ##  [71] "junkyard riffle #4"                     
    ##  [72] "cox riffle #3"                          
    ##  [73] "hour bars #1"                           
    ##  [74] "g95 #5"                                 
    ##  [75] "gateway riffle"                         
    ##  [76] "vance ave"                              
    ##  [77] "eye riffle 4"                           
    ##  [78] "weir rffle #1"                          
    ##  [79] "steep riffle #3"                        
    ##  [80] "hatchery riffle #3"                     
    ##  [81] "trailer park riffl e#4"                 
    ##  [82] "mathews riffle #3"                      
    ##  [83] "robinson side channel #1"               
    ##  [84] "steep side riffle #2"                   
    ##  [85] "robinson riffle #2"                     
    ##  [86] "herringer side #2"                      
    ##  [87] "shallow side #1"                        
    ##  [88] "shallow riffle #3"                      
    ##  [89] "weir #2"                                
    ##  [90] "eye"                                    
    ##  [91] "robinson side #2"                       
    ##  [92] "steep main #2"                          
    ##  [93] "mathews #5"                             
    ##  [94] "robinsoon main #2"                      
    ##  [95] "macfarland"                             
    ##  [96] "lower big hole #1"                      
    ##  [97] "vance ave #5"                           
    ##  [98] "g95 east #1"                            
    ##  [99] "goose riffle #1"                        
    ## [100] "gridley riffle (sidechannel) #1"        
    ## [101] "cox riffle #4"                          
    ## [102] "shallow riffle 3 (side channel)"        
    ## [103] "g-95"                                   
    ## [104] "steep riffle #2"                        
    ## [105] "robinson riffle #4"                     
    ## [106] "robinson side channel #3"               
    ## [107] "shallow riffle (main)"                  
    ## [108] "herringer main channel #1"              
    ## [109] "vance #5"                               
    ## [110] "big hole lower #2"                      
    ## [111] "mcfarland riffle"                       
    ## [112] "big bar #1"                             
    ## [113] "junkyard riffle #2"                     
    ## [114] "lower hour riffle"                      
    ## [115] "bedrock park #3"                        
    ## [116] "aleck riffle #2"                        
    ## [117] "trialer park #3"                        
    ## [118] "mathews riffle #1"                      
    ## [119] "eye side channel #2"                    
    ## [120] "steep side #2"                          
    ## [121] "mathews #2"                             
    ## [122] "gateway riffle #4"                      
    ## [123] "eye riffle #3"                          
    ## [124] "vance ave. #1"                          
    ## [125] "g-95 (section 4)"                       
    ## [126] "robinson side #4"                       
    ## [127] "aleck #1"                               
    ## [128] "steep main #1"                          
    ## [129] "cox riffle"                             
    ## [130] "shallow riffle west #3"                 
    ## [131] "g-95 east"                              
    ## [132] "hour riffle (lower)"                    
    ## [133] "mcfarland"                              
    ## [134] "cox riffle section 3"                   
    ## [135] "shallow riffle section 2"               
    ## [136] "junkyard riffle section 2"              
    ## [137] "grifley riffle"                         
    ## [138] "steep main channel"                     
    ## [139] "steep side #3"                          
    ## [140] "aleck riffle sect 3"                    
    ## [141] "bedrock park #4"                        
    ## [142] "hatchery ditch #3"                      
    ## [143] "trailer park #1"                        
    ## [144] "eye side #2"                            
    ## [145] "eye #2"                                 
    ## [146] "gateway"                                
    ## [147] "hour section 2"                         
    ## [148] "shallow main section 1"                 
    ## [149] "junkyard section 1"                     
    ## [150] "cox riffle #5"                          
    ## [151] "mcfarland #1"                           
    ## [152] "g-95 east #3"                           
    ## [153] "g95 west #4"                            
    ## [154] "vance east #6"                          
    ## [155] "goose section 2"                        
    ## [156] "hour east riffle"                       
    ## [157] "weir section 1"                         
    ## [158] "steep side channel #3"                  
    ## [159] "weir riffle #2"                         
    ## [160] "gridley riffle #3"

``` r
# FIX aleck riffle and alec riffle
# FIX hatchery  ditch and hatchery ditch
```

**NA and Unknown Values**

There are 0 NA values

### Variable: `species`

``` r
table(all_fish_data$species) 
```

    ## 
    ##             Chinook salmon       Sacramento squawfish 
    ##                        293                         17 
    ##              Speckled dace     Steelhead trout (wild) 
    ##                          6                        294 
    ## Steelhead trout, (clipped)                 Tule perch 
    ##                          5                          5

Fix inconsistencies with spelling, capitalization, and abbreviations.

**NA and Unknown Values**

There are 9207 NA values

### Variable: `channel_geomorphic_unit`

``` r
table(all_fish_data$channel_geomorphic_unit) 
```

    ## 
    ##        Backwater            Glide  Glide Edgewater             Pool 
    ##              236             3867             1594             1926 
    ##           Riffle Riffle Edgewater 
    ##             1016              389

**NA and Unknown Values**

There are 799 NA values

### Variable: `gps_coordinate`

``` r
table(all_fish_data$gps_coordinate) 
```

    ## 
    ##          39 21.224, 121 37.831       39 22.566' N 121 37.949' 
    ##                             36                             36 
    ##          39 27.706  121 36.109          39 27.771  121 36.257 
    ##                             36                             36 
    ##       39 29.09' N 121 37.82' W          39 30.950, 121 33.552 
    ##                             36                             36 
    ##           39.27.957 121.35.991           39.28.981 121.34 736 
    ##                             37                             36 
    ##           39.29.058 121.34.742        39' 27.68', 121' 36.48' 
    ##                             36                             36 
    ##         39°23.167'N 121°37.722        39°25.304'N 121°37.540W 
    ##                             36                             36 
    ##                             70     N 31º 29.68  W 121º 34.765 
    ##                             35                             35 
    ##    N 39  24.340  W 121  37.030      N 39 19.065  W 121 37.381 
    ##                             36                             36 
    ##       N 39 19.212 W 121 37.185        N 39 19.743 W121 37.729 
    ##                             36                             36 
    ##       N 39 19.752 W 121 37.830       N 39 19.842 W 121 37.787 
    ##                             36                             37 
    ##       N 39 19.885 W 121 37.821       N 39 19.905 W 121 37.870 
    ##                             36                             36 
    ##       N 39 20.093 W 121 37.945       N 39 20.170 W 121 37.874 
    ##                             36                             36 
    ##       N 39 20.180 W 121 37.945       N 39 20.729 W 121 37.571 
    ##                             36                             36 
    ##       N 39 20.752 W 121 37.601       N 39 20.755 W 121 37.601 
    ##                             36                             37 
    ##       N 39 20.812 W 121 37.594         N 39 21.27 W 121 37.85 
    ##                             37                             36 
    ##       N 39 21.311 W 121 38.003           N 39 22.4 W 121 38.0 
    ##                             36                             36 
    ##       N 39 22.405 W 121 38.108       N 39 22.498 W 121 37.935 
    ##                             36                             36 
    ##       N 39 23.160 W 121 37.699       N 39 23.176 W 121 37.701 
    ##                             36                             36 
    ##       N 39 23.178 W 121 37.700       N 39 23.185 W 121 37.681 
    ##                             36                             36 
    ##       N 39 24.265 W 121 37.043           N 39 24.9 W 121 37.6 
    ##                             36                             36 
    ##            N 39 24.9 W121 37.6       N 39 24.928 W 121 37.618 
    ##                             36                             36 
    ##       N 39 25.020 W 121 37.531        N 39 25.24 W 121 37.549 
    ##                             36                             36 
    ##       N 39 25.265 W 121 37.565       N 39 25.715 W 121 37.544 
    ##                             36                             36 
    ##       N 39 25.746 W 121 37.570       N 39 25.790 W 121 37.669 
    ##                             36                             37 
    ##       N 39 25.818 W 121 37.834       n 39 25.828 W 121 37.734 
    ##                             36                             36 
    ##       N 39 25.828 W 121 37.854       N 39 25.839 W 121 37.898 
    ##                             36                             36 
    ##         N 39 26.24 W 121 38.25       N 39 26.241 W 121 35.250 
    ##                             36                             36 
    ##       N 39 26.278 W 121 38.259       N 39 26.291 W 121 38.266 
    ##                             36                             36 
    ##       N 39 26.391 W 121 38.276       N 39 26.591 W 121 38.215 
    ##                             36                             36 
    ##       N 39 26.798 W 121 38.272       N 39 26.885 W 121 38.151 
    ##                             36                             34 
    ##       N 39 26.970 W 121 33.318       N 39 27.003 W 121 38.346 
    ##                             36                             36 
    ##       N 39 27.196 W 121 36.887       n 39 27.409 w 121 37.533 
    ##                             36                             37 
    ##       N 39 27.416 W 121 36.910         N 39 27.42 W 121 37.40 
    ##                             41                             36 
    ##       N 39 27.421 W 121 37.386       N 39 27.426 W 121 36.857 
    ##                             36                             36 
    ##       N 39 27.428 W 121 36.797       N 39 27.429 W 121 36.786 
    ##                             38                             36 
    ##       N 39 27.444 W 121 36.791      N 39 27.449  W 121 36.790 
    ##                             38                             36 
    ##       N 39 27.652 W 121 36.544       n 39 27.674 W 121 36.257 
    ##                             36                             36 
    ##         N 39 27.68 w 121 36.54       N 39 27.702 W 121 36.112 
    ##                             36                             36 
    ##       N 39 27.737 W 121 36.282       N 39 27.747 W 121 36.282 
    ##                             36                             36 
    ##       N 39 27.756 W 121 36.214       N 39 27.756 W 121 36.262 
    ##                             36                             36 
    ##        N 39 27.756 W 21 36.961        N 39 27.757 W121 36.217 
    ##                             36                             38 
    ##       N 39 27.808 W 121 36.241       N 39 27.871 W 121 35 927 
    ##                             36                             36 
    ##       N 39 27.914 W 121 35.844       N 39 27.925 W 121 35.845 
    ##                             36                             36 
    ##        N 39 27.954 W121 36.019       N 39 28.000 W 121 35.956 
    ##                             37                             36 
    ##        N 39 29.028 W121 34.734       N 39 29.033 W 121 34.729 
    ##                             36                             36 
    ##       N 39 29.058 W 121 34.742       N 39 29.419 W 121 34.705 
    ##                             36                             46 
    ##       n 39 29.456 w 121 34.747       N 39 29.514 W 121 34.734 
    ##                             36                             36 
    ##       N 39 29.573 W 121 34.796        N 39 29.686 W121 34.766 
    ##                             36                             36 
    ##       N 39 29.768 W 121 34.760    N 39 29.806Min  W120 34.768 
    ##                             36                             36 
    ##       N 39 30.356 W 121 33.461       N 39 30.774 W 121 34.224 
    ##                             48                             36 
    ##       N 39 30.786 W 121 34.096      N 39 30.938  W 121 33.391 
    ##                             39                             37 
    ##       N 39 30.942 W 121 33.553       N 39 30.949 W 121 33.271 
    ##                             37                             40 
    ##       N 39 30.963 W 121 33.555       N 39 30.966 W 121 33.270 
    ##                             46                             43 
    ##       N 39 30.973 W 121 33.499       N 39 30.998 W 121 33.427 
    ##                             42                             43 
    ##      N 39* 19.055, W 21*37.394  N 39* 19.056'  W 121* 37.394' 
    ##                             36                             36 
    ##  N 39* 19.747   W 121*  37.729  N 39* 19.757'  W 121* 37.841' 
    ##                             36                             36 
    ##   N 39* 20.733'  W 121* 37.574    N 39* 21.315  W 121* 38.003 
    ##                             36                             36 
    ##  N 39* 22.523'  W 121* 37.945'     N 39* 25.82   W 121* 37.84 
    ##                             36                             36 
    ##  N 39* 27.755', W 121* 36.201'  N 39* 27.804', W 121* 36.240' 
    ##                             39                             36 
    ##   N 39* 27.979', W 121* 35.922    N 39* 30.537' W121* 30.315' 
    ##                             36                             36 
    ##      N 39* 30.783, W 21*34.089    N 39* 30.952,  W 21* 33.215 
    ##                             36                             38 
    ##      N 39*23.154' W121*37.723'   N 39*27.758', w 121* 36.263' 
    ##                             36                             36 
    ##       n 39*30.950, w 21*33.212      N 39° 19.14 W 121° 37.22' 
    ##                             36                             36 
    ##     N 39° 19.743 W 121° 37.741         N 39° 20.8 W 121° 37.6 
    ##                             36                             36 
    ##    N 39° 22.50'  W 121° 37.94'  N 39° 23.188'  W 121° 37.671' 
    ##                             35                             36 
    ##  N 39° 24.197'  W 121° 37.094'    N 39° 24.27'  W 121° 37.02' 
    ##                             36                             37 
    ##    N 39° 24.95'  W 121° 37.60'    N 39° 25.24'  W 121° 37.54' 
    ##                             35                             36 
    ##    N 39° 25.75'  W 121° 37.57'  N 39° 25.863'  W 121° 37.934' 
    ##                             37                             37 
    ##  N 39° 25.882'  W 121° 37.932'     N 39° 26.24'  W 121° 38.28 
    ##                             36                             37 
    ##    N 39° 26.24'  W 121° 38.28'  N 39° 26.289'  W 121° 38.260' 
    ##                             34                             36 
    ##  N 39° 26.362'  W 121° 38.220'  N 39° 26.592'  W 121° 38.209' 
    ##                             35                             34 
    ##  N 39° 26.592'  W 121° 38.212'  N 39° 26.601'  W 121° 38.228' 
    ##                             34                             38 
    ##  N 39° 27.435'  W 121° 36.834'  N 39° 27.452'  W 121° 36.788' 
    ##                             35                             37 
    ##  N 39° 27.705'  W 121° 36.387'  N 39° 27.754'  W 121° 36.194' 
    ##                             36                             35 
    ##  N 39° 27.795'  W 121° 36.241'  N 39° 27.796'  W 121° 36.242' 
    ##                             36                             36 
    ##   N 39° 27.895'  W 121° 35.857  N 39° 27.976'  W 121° 35.981' 
    ##                             36                             36 
    ##  N 39° 29.012'  W 121° 34.740'  N 39° 29.052'  W 121° 34.755' 
    ##                             76                             36 
    ##   N 39° 29.103'  W 121* 34.740  N 39° 29.103'  W 121* 34.740' 
    ##                              1                             37 
    ##  N 39° 30.750'  W 121° 34.166'   N 39° 30.906'  W 121° 33.600 
    ##                             37                             36 
    ##    N 39° 30.92'  W 121° 33.54'    N 39° 30.94'  W 121° 33.28' 
    ##                             42                             39 
    ##   N 39° 30.987'  W 121° 33.46'      N 39°19.068" W 121°37.256 
    ##                             36                             35 
    ##     N 39°19.734' W 121°37.791'       N 39°21.261 W 121°37.779 
    ##                             36                             37 
    ##      N 39°22.503 W 121° 37.942   N 39º 19.139'  W 121º 37.216 
    ##                             37                             36 
    ##     N 39º 24.319'  W 121º 36.9   N 39º 24.319'  W 121º 36.976 
    ##                              2                             36 
    ##    N 39º 27.814  W 121º 36.234   N 39º 27.962'  W121º 35.980' 
    ##                             36                             35 
    ##   N 39º 27.982'  W 121º 35.920     N 39º 27.983  W 121º 35.91 
    ##                             36                              1 
    ##    N 39º 27.983  W 121º 35.919   N 39º 29.066'  W121º 34.739' 
    ##                             36                             39 
    ## N 39º 29.575'   W 121º 34.795'     N 39º 29.642, W121º 34.801 
    ##                             36                             36 
    ##   N 39º 30.519'  W 121º 30.288   N 39º 30.961'  W 121º 33.529 
    ##                             36                             37 
    ##      N: 39.29.084 W:121.34.741      N. 39 20.132 W 121 37.929 
    ##                             37                             36 
    ##     N. 39.26.122 W. 121.38.204     N. 39.27.424  W:121.36.863 
    ##                             36                             36 
    ##          N39 19758 W121 37.729         N39 25.270 W121 37.550 
    ##                             36                             36 
    ##           N39 25.74 W121 37.57         N39 26.250 W121 38.250 
    ##                             36                             36 
    ##       N39 26.320  W121  38.227         N39 27.730 W121 36.290 
    ##                             36                             36 
    ##           N39 27.87 W121 35.95           N39 27.95 W121 36.03 
    ##                             36                             36 
    ##         N39 29.643 W121 34.792        N39 30.770 W 121 34.145 
    ##                             36                             37 
    ##        N39 30.947 W 121 33.272  N39*  25.824    W121*  37.850 
    ##                             36                             37 
    ##       N39*19.765', W121*37.72'      N39*21.247', W121*37.835' 
    ##                             36                             36 
    ##        N39*23.155  W121*37.722         N39*24.340 W121*37.029 
    ##                             36                             36 
    ##    N39º 20.738', W121º 37.576'     N39º 24.321', W121º 36.982 
    ##                             36                             34 
    ##                           None                      not taken 
    ##                            108                             36

**NA and Unknown Values**

There are 2455 NA values

### Variable: `weather`

``` r
table(all_fish_data$weather) 
```

    ## 
    ## Direct Sunlight        Overcast   Precipitation 
    ##            8628            1086             113

**NA and Unknown Values**

There are 0 NA values

### Variable: `channel_type`

``` r
table(all_fish_data$channel_type) 
```

    ## 
    ##        Mainchannel Mainchannel Branch        Sidechannel 
    ##               4726               2386               2570

**NA and Unknown Values**

There are 145 NA values

## Summary of identified issues

- percent cover that is \> or \< 100%
- did some location name clean up but could be better
- remove sac squawfish
- other?

``` r
microhabitat_with_fish_detections <- all_fish_data |> 
  rename(transect_code = t_code,
         location_table_id = p_dat_id,
         surface_turbidity = sur_turb) |> 
  mutate(species = tolower(species),
         species = ifelse(species == "sacramento squawfish","sacramento pikeminnow", species),
         count = ifelse(is.na(count), 0, count),
         channel_geomorphic_unit = tolower(channel_geomorphic_unit),
         channel_geomorphic_unit = case_when(channel_geomorphic_unit == "glide edgewater" ~ "glide margin",
                                             channel_geomorphic_unit == "riffle edgewater" ~ "riffle margin",
                                             T ~ channel_geomorphic_unit)) |> 
  select(micro_hab_data_tbl_id, location_table_id, transect_code, fish_data_id, date, count, species, fl_mm, dist_to_bottom, depth, focal_velocity, velocity, surface_turbidity, percent_fine_substrate, percent_sand_substrate, percent_small_gravel_substrate, percent_large_gravel_substrate, percent_cobble_substrate, percent_boulder_substrate, percent_no_cover_inchannel, percent_small_woody_cover_inchannel, percent_large_woody_cover_inchannel, percent_submerged_aquatic_veg_inchannel, percent_undercut_bank, percent_no_cover_overhead, percent_cover_half_meter_overhead, percent_cover_more_than_half_meter_overhead, channel_geomorphic_unit)
  
# TODO make sure the location names that we end with are lowercase
survey_locations <- all_fish_data |> 
  rename(transect_code = t_code,
         location_table_id = p_dat_id) |> 
  mutate(weather = tolower(weather),
         channel_type = tolower(channel_type),
         location_revised = case_when(location %in% c("across big hole island ( river right)", "across from big hole", "across from big hole boat ramp", "big hole island") ~ "big hole",
                              location == "auditorium" ~ "auditorium riffle",
                              location %in% c("bedrock", "bedrock park", "bedrock park, unit #50") ~ "bedrock riffle",
                              location == "big bar - middle island river right" ~ "big bar",
                              grepl("eye riffle", location) ~ "eye riffle",
                              location %in% c("east g 95", "g 95", "g-95 side channel", "g95", "g95 (area)", "g95 east", "g95 rr downstream head", "g95 west side channel") ~ "g95",
                              location == "gridley side channel" ~ "gridley riffle",
                              grepl("herringer", location) ~ "herringer riffle",
                              location == "junkyard" ~ "junkyard riffle",
                              location == "lower hole" ~ "lower big hole",
                              location == "lower hour side channel" ~ "lower hour",
                              location == "mathews riffle" ~ "matthews riffle",
                              location == "mcfarland riffle`" ~ "mcfarland riffle",
                              grepl("trailer park", location) ~ "trailer park riffle",
                              grepl("robinson", location) ~ "robinson riffle",
                              grepl("shallow", location) ~ "shallow riffle",
                              grepl("steep", location) ~ "steep riffle",
                              grepl("vance", location) ~ "vance riffle",
                              grepl("weir", location) ~ "weir riffle",
                              T ~ location)) |> 
  select(location_table_id, date, location, location_revised, water_temp, 
        weather, river_mile, flow, number_of_divers, 
        reach_length, reach_width, channel_width, 
        channel_type, gps_coordinate) |> 
  distinct()
  
sort(unique(survey_locations$location))
```

    ##   [1] "across big hole island ( river right)"  
    ##   [2] "across from big hole"                   
    ##   [3] "across from big hole boat ramp"         
    ##   [4] "aleck #1"                               
    ##   [5] "aleck riffle"                           
    ##   [6] "aleck riffle #2"                        
    ##   [7] "aleck riffle sect 3"                    
    ##   [8] "auditorium"                             
    ##   [9] "auditorium riffle"                      
    ##  [10] "auditorium#3"                           
    ##  [11] "bedrock"                                
    ##  [12] "bedrock park"                           
    ##  [13] "bedrock park #3"                        
    ##  [14] "bedrock park #4"                        
    ##  [15] "bedrock park, unit #50"                 
    ##  [16] "bedrock riffle"                         
    ##  [17] "big bar"                                
    ##  [18] "big bar - middle island river right"    
    ##  [19] "big bar #1"                             
    ##  [20] "big hole"                               
    ##  [21] "big hole island"                        
    ##  [22] "big hole lower #2"                      
    ##  [23] "cox riffle"                             
    ##  [24] "cox riffle #3"                          
    ##  [25] "cox riffle #4"                          
    ##  [26] "cox riffle #5"                          
    ##  [27] "cox riffle section 3"                   
    ##  [28] "east g 95"                              
    ##  [29] "eye"                                    
    ##  [30] "eye #2"                                 
    ##  [31] "eye riffle"                             
    ##  [32] "eye riffle #3"                          
    ##  [33] "eye riffle 4"                           
    ##  [34] "eye riffle main channel"                
    ##  [35] "eye riffle side"                        
    ##  [36] "eye riffle side channel"                
    ##  [37] "eye riffle, unit #208"                  
    ##  [38] "eye side #2"                            
    ##  [39] "eye side channel"                       
    ##  [40] "eye side channel #2"                    
    ##  [41] "g 95"                                   
    ##  [42] "g-95"                                   
    ##  [43] "g-95 (section 4)"                       
    ##  [44] "g-95 east"                              
    ##  [45] "g-95 east #3"                           
    ##  [46] "g-95 side channel"                      
    ##  [47] "g95"                                    
    ##  [48] "g95 (area)"                             
    ##  [49] "g95 #5"                                 
    ##  [50] "g95 east"                               
    ##  [51] "g95 east #1"                            
    ##  [52] "g95 rr downstream head"                 
    ##  [53] "g95 west #4"                            
    ##  [54] "g95 west side channel"                  
    ##  [55] "gateway"                                
    ##  [56] "gateway riffle"                         
    ##  [57] "gateway riffle #4"                      
    ##  [58] "goose riffle"                           
    ##  [59] "goose riffle #1"                        
    ##  [60] "goose section 2"                        
    ##  [61] "gridley riffle"                         
    ##  [62] "gridley riffle (sidechannel) #1"        
    ##  [63] "gridley riffle #1"                      
    ##  [64] "gridley riffle #3"                      
    ##  [65] "gridley side channel"                   
    ##  [66] "grifley riffle"                         
    ##  [67] "hatchery ditch"                         
    ##  [68] "hatchery ditch #3"                      
    ##  [69] "hatchery riffle"                        
    ##  [70] "hatchery riffle #3"                     
    ##  [71] "herringer"                              
    ##  [72] "herringer main channel #1"              
    ##  [73] "herringer main river left"              
    ##  [74] "herringer riffle"                       
    ##  [75] "herringer side #2"                      
    ##  [76] "hour bars"                              
    ##  [77] "hour bars #1"                           
    ##  [78] "hour east riffle"                       
    ##  [79] "hour riffle"                            
    ##  [80] "hour riffle (lower)"                    
    ##  [81] "hour section 2"                         
    ##  [82] "junkyard"                               
    ##  [83] "junkyard riffle"                        
    ##  [84] "junkyard riffle #2"                     
    ##  [85] "junkyard riffle #4"                     
    ##  [86] "junkyard riffle section 2"              
    ##  [87] "junkyard section 1"                     
    ##  [88] "lower big hole"                         
    ##  [89] "lower big hole #1"                      
    ##  [90] "lower hole"                             
    ##  [91] "lower hour"                             
    ##  [92] "lower hour riffle"                      
    ##  [93] "lower hour side channel"                
    ##  [94] "lower robinson"                         
    ##  [95] "macfarland"                             
    ##  [96] "macfarland riffle"                      
    ##  [97] "mathews #2"                             
    ##  [98] "mathews #5"                             
    ##  [99] "mathews riffle"                         
    ## [100] "mathews riffle #1"                      
    ## [101] "mathews riffle #3"                      
    ## [102] "matthews riffle"                        
    ## [103] "mcfarland"                              
    ## [104] "mcfarland #1"                           
    ## [105] "mcfarland riffle"                       
    ## [106] "mcfarland riffle`"                      
    ## [107] "river right below vance ave bridge"     
    ## [108] "robinson main channel"                  
    ## [109] "robinson riffle"                        
    ## [110] "robinson riffle #2"                     
    ## [111] "robinson riffle #4"                     
    ## [112] "robinson side #2"                       
    ## [113] "robinson side #4"                       
    ## [114] "robinson side channel"                  
    ## [115] "robinson side channel #1"               
    ## [116] "robinson side channel #3"               
    ## [117] "robinsoon main #2"                      
    ## [118] "shallow"                                
    ## [119] "shallow main section 1"                 
    ## [120] "shallow riffle"                         
    ## [121] "shallow riffle (main)"                  
    ## [122] "shallow riffle #3"                      
    ## [123] "shallow riffle 3 (side channel)"        
    ## [124] "shallow riffle section 2"               
    ## [125] "shallow riffle side"                    
    ## [126] "shallow riffle west #3"                 
    ## [127] "shallow side #1"                        
    ## [128] "steep main #1"                          
    ## [129] "steep main #2"                          
    ## [130] "steep main channel"                     
    ## [131] "steep riffle"                           
    ## [132] "steep riffle #2"                        
    ## [133] "steep riffle #3"                        
    ## [134] "steep side #2"                          
    ## [135] "steep side #3"                          
    ## [136] "steep side channel"                     
    ## [137] "steep side channel #3"                  
    ## [138] "steep side riffle"                      
    ## [139] "steep side riffle #2"                   
    ## [140] "trailer park"                           
    ## [141] "trailer park #1"                        
    ## [142] "trailer park riffl e#4"                 
    ## [143] "trailer park riffle"                    
    ## [144] "trailer park, unit #98"                 
    ## [145] "trialer park #3"                        
    ## [146] "upper big hole"                         
    ## [147] "vance (300 yards below-rr-right channel"
    ## [148] "vance #5"                               
    ## [149] "vance ave"                              
    ## [150] "vance ave #5"                           
    ## [151] "vance ave. #1"                          
    ## [152] "vance avenue"                           
    ## [153] "vance avenue bl - river left"           
    ## [154] "vance east #6"                          
    ## [155] "weir"                                   
    ## [156] "weir #2"                                
    ## [157] "weir rffle #1"                          
    ## [158] "weir riffle"                            
    ## [159] "weir riffle #2"                         
    ## [160] "weir section 1"

### Fixing location names and adding coordinates

``` r
# Ryon reviewed the list of revised locations and provided some changes
rk_revised <- read_csv(here::here("data-raw", "check_locations_4ryon_rk.csv")) |>
  rename(location = existing_location_name) |>
  distinct() |>
  filter(revised_location_name != "trailer park")
```

    ## Rows: 136 Columns: 2
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (2): existing_location_name, revised_location_name
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
survey_locations_revised <- survey_locations |> 
  left_join(rk_revised) |> 
  mutate(location = revised_location_name) |> 
  select(-c(location_revised, revised_location_name)) 
```

    ## Joining with `by = join_by(location)`

``` r
write_csv(survey_locations_revised, here::here("data-raw","survey_locations_revised.csv"))

# Ashley used google to QC the coordinates- looked up coordinates by entering 39 (deg symbol) XX.XXN 121 (deg symbol) XX.XXW
survey_locations_google <- read_csv(here::here("data-raw", "survey_locations_revised_av.csv"))
```

    ## Rows: 136 Columns: 15
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (6): date, location, weather, channel_type, gps_coordinate, longitude_go...
    ## dbl (9): location_table_id, water_temp, river_mile, flow, number_of_divers, ...
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
# badhia pulled coordinates from kmz Casey provided, use this to try and associate coordinates with the locations (https://netorg629193.sharepoint.com/:u:/s/VA-FeatherRiver/EeHO1UrPtzVMiO1lFkFTBQwBhTzsveQ6d62gZv7fbxVldg?e=hSjJDR)
# There are multiple coordinates for each location so take the average
detach("package:Hmisc", unload = TRUE)
coordinates_from_kmz_raw <- read_csv(here::here("data-raw", "Coordinates_Snorkel_Survey_Locations.csv"))
```

    ## Rows: 4721 Columns: 3
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (1): Name
    ## dbl (2): Longitude, Latitude
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
coordinates_from_kmz <- coordinates_from_kmz_raw |> 
  rename(location = Name) |> 
  mutate(location = tolower(location)) |> 
  group_by(location) |> 
  summarize(longitude = mean(Longitude),
            latitude = mean(Latitude)) |> 
  # adjusting some names to match with the survey locations
  mutate(location = case_when(location == "alec riffle" ~ "aleck riffle",
                              location == "bedrock riffle" ~ "bedrock park riffle",
                              location == "g95 side channel" ~ "g95",
                              location == "gridley side channel" ~ "gridley riffle",
                              location == "upper mcfarland" ~ "macfarland riffle",
                              location == "vance west" ~ "vance avenue",
                              T ~ location))
# find an average lat/long by location name
coordinate_from_google <- survey_locations_google |> 
    mutate(longitude_google = ifelse(location_table_id %in% c(25,34,112), NA, longitude_google),
         longitude_google = as.numeric(longitude_google)) |> 
  group_by(location) |> 
  summarize(longitude_google = mean(longitude_google, na.rm = T),
            latitude_google = mean(latitude_google, na.rm = T))

# summary of assigning coordinates
# 1. use the coordinates reported in the db (if when QCd the coordinate makes sense), convert to lat/long
# 2. for missing coordinates use the average location level as provided by Casey in kmz file or the average location level as reported

# following these steps we have 2 missing coordinates for sites - hour riffle and upper big hole
location_coordinates <- survey_locations_google |> 
  select(location_table_id, location, river_mile, longitude_google, latitude_google) |> 
  mutate(longitude_google = ifelse(location_table_id %in% c(25,34,112), NA, longitude_google),
         longitude_google = as.numeric(longitude_google)) |> 
  left_join(coordinates_from_kmz) |> 
  mutate(coordinate_method = case_when(!is.na(longitude_google) ~ "reported in database",
                                       is.na(longitude_google) & !is.na(longitude) ~ "kmz from casey"),
         longitude_google = case_when(is.na(longitude_google) & !is.na(longitude) ~ longitude,
                                      T ~ longitude_google),
         latitude_google = case_when(is.na(latitude_google) & !is.na(latitude) ~ latitude,
                                     T ~ latitude_google)) |> 
  select(location_table_id, location, river_mile, longitude_google, latitude_google, coordinate_method) |> 
  rename(longitude = longitude_google,
         latitude = latitude_google) |> 
  left_join(coordinate_from_google) |> 
  mutate(coordinate_method = case_when(is.na(longitude) & !is.na(longitude_google) ~ "location average",
                                       T ~ coordinate_method),
         longitude = case_when(is.na(longitude) & !is.na(longitude_google) ~ longitude_google,
                                      T ~ longitude),
         latitude = case_when(is.na(latitude) & !is.na(latitude_google) ~ latitude_google,
                                     T ~ latitude)) |> 
  select(-c(longitude_google, latitude_google))
```

    ## Joining with `by = join_by(location)`
    ## Joining with `by = join_by(location)`

``` r
survey_locations_with_latlong <- survey_locations_revised |> 
  select(-gps_coordinate, -river_mile) |>  # this field is messy and was converted to lat/long so removing
  left_join(location_coordinates)
```

    ## Joining with `by = join_by(location_table_id, location)`

``` r
write_csv(survey_locations_with_latlong, here::here("data", "survey_locations.csv"))
```

``` r
ryon_coordinates <- readxl::read_xlsx(here::here("data-raw", "survey_locations_name_cleanup_rk.xlsx"))

locations_ck <- survey_locations_with_latlong |> 
  left_join(ryon_coordinates |> 
  rename(rk_latitude = latitude,
         rk_longitude = longitude,
         rk_location = location,
         rk_location_revised = location_revised,
         channel_location = channel) |> 
    select(location_table_id, rk_location, rk_location_revised, rk_latitude, rk_longitude, channel_location))
```

    ## Joining with `by = join_by(location_table_id)`

``` r
# there are some locations where ryon updated name
locations_ck |> 
  filter(location != rk_location_revised)
```

    ## # A tibble: 13 × 20
    ##    location_table_id date       location            water_temp weather      flow
    ##                <dbl> <date>     <chr>                    <dbl> <chr>       <dbl>
    ##  1                15 2001-08-20 trailer park riffle         58 direct sun…   600
    ##  2                16 2001-08-20 bedrock park riffle         58 direct sun…   600
    ##  3                37 2001-07-11 trailer park riffle         59 direct sun…   600
    ##  4                37 2001-07-11 trailer park riffle         59 direct sun…   600
    ##  5                40 2001-07-12 bedrock park riffle         58 direct sun…   600
    ##  6                41 2001-07-12 eye riffle                  63 direct sun…   600
    ##  7                55 2001-06-11 bedrock park riffle         56 overcast      600
    ##  8                56 2001-06-11 trailer park riffle         57 direct sun…   600
    ##  9                73 2001-05-22 bedrock park riffle         55 direct sun…   600
    ## 10               110 2001-08-21 eye riffle                  62 direct sun…   700
    ## 11               112 2001-04-09 trailer park riffle         52 direct sun…   600
    ## 12               139 2001-03-14 bedrock park riffle         50 direct sun…   600
    ## 13               140 2001-03-14 trailer park riffle         52 direct sun…   600
    ## # ℹ 14 more variables: number_of_divers <dbl>, reach_length <dbl>,
    ## #   reach_width <dbl>, channel_width <dbl>, channel_type <chr>,
    ## #   river_mile <dbl>, longitude <dbl>, latitude <dbl>, coordinate_method <chr>,
    ## #   rk_location <chr>, rk_location_revised <chr>, rk_latitude <dbl>,
    ## #   rk_longitude <dbl>, channel_location <chr>

``` r
survey_locations_post_ryon_revisions <- locations_ck |> 
  mutate(location = rk_location_revised,
         rk_latitude = ifelse(is.na(rk_latitude), latitude, rk_latitude),
         rk_longitude = ifelse(is.na(rk_longitude), longitude, rk_longitude),
         coordinate_method = case_when(coordinate_method %in% c("location average","kmz from casey") | is.na(coordinate_method) ~ "assigned based on similar location",
                                       T ~ coordinate_method)) |> # assume all from ryon are assigned from similar location (these are the same ones that I tried to fill in)
  select(-c(latitude, longitude, rk_location, rk_location_revised)) |> 
  rename(latitude = rk_latitude,
         longitude = rk_longitude)

# i plotted these locations on the map and noticed some disconnect between the name and coordinate
# suggested to ryon that we update these coordinates based on his method of selecting another with same name, he agreed
#      * 79 - Location name = eye riffle. This is how name was reported on database. Coordinates were reported in the database, but when mapped it shows next to aleck riffle. Adjust coordinates to be near eye riffle?
     # * 78 - Location name = eye riffle. This is how name was reported on database. Coordinates were reported in the database, but when mapped it shows next to aleck riffle. Adjust coordinates to be near eye riffle?
     # * 68 - Location name = g95. Coordinates were reported in the database, but when mapped it shows next to lower big hole. Adjust coordinates to be near g95?
     # * 102 - Location name = g95. Coordinates were reported in the database, but when mapped it shows next to lower big hole. Adjust coordinates to be near g95?
     # * 146 - Location name = big bar. Shows up near Goose Riffle. This is one of the coordinates you changed.
     # * 30 - Location name = macfarland riffle. Shows up near Big Bar. Adjust coordinates?
     # * 27 - Location name = gridley riffle. Shows up near macfarland riffle. Adjust coordinates?

coordinate_by_name <- survey_locations_post_ryon_revisions |> 
  filter(!location_table_id  %in% c(79, 78, 68, 102, 146, 30, 27)) |> 
  select(location, latitude, longitude) |> 
  group_by(location) |> 
  slice_head() |> 
  rename(loc_lat = latitude,
         loc_long = longitude)

survey_locations_post_ryon_revisions_qc <- survey_locations_post_ryon_revisions |> 
  left_join(coordinate_by_name) |> 
  mutate(latitude = ifelse(location_table_id  %in% c(79, 78, 68, 102, 146, 30, 27), loc_lat, latitude),
         longitude = ifelse(location_table_id %in% c(79, 78, 68, 102, 146, 30, 27), loc_long, longitude),
         coordinate_method = ifelse(location_table_id %in% c(79, 78, 68, 102, 146, 30, 27), "assigned based on similar location", coordinate_method)) |> 
  select(location_table_id, date, location, channel_location, water_temp, weather, flow, number_of_divers, reach_length, reach_width, channel_width, channel_type, river_mile, coordinate_method, latitude, longitude)
```

    ## Joining with `by = join_by(location)`

``` r
# these edits were mapped and there are no longer any disconnect between the location name and coordinates
```

## Save cleaned data to data/

``` r
# Save to data folder
# Name file [watershed]_[data type].csv
write_csv(microhabitat_with_fish_detections, here::here("data", "microhabitat_observations.csv"))
#write_csv(survey_locations, "data/survey_locations.csv")
write_csv(survey_locations_post_ryon_revisions_qc, here::here("data", "survey_locations.csv"))

# create list of existing locations and revised locations for casey and ryon to check
# check_locations <- survey_locations |> 
#   select(location, location_revised) |> 
#   rename(existing_location_name = location,
#          revised_location_name = location_revised)
# write_csv(check_locations, "data-raw/check_locations_4ryon.csv")
# TODO add coordinates for survey locations
# From Casey kmz we have the following: aleck riffle, auditorium riffle, bedrock riffle, eye riffle, eye side channel, g95, goose riffle, gridley riffle, hatchery riffle, junkyard riffle, matthews riffle, robinson riffle, steep riffle, trailer park riffle, vance riffle
# Missing big bar, big hole, hatchery ditch, herringer riffle, hour bars, hour riffle, lower big hole, lower hour, mcfarland riffle, shallow riffle, upper big hole, weir riffle
```
