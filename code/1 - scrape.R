# Billboard Hot 100 Artist
# https://www.billboard.com/charts/year-end/2019/hot-100-artists

library(tidyverse)
library(rvest)

# scrape
datalist = list()
counter = 1
for (i in 2005:2019) {
  Sys.sleep(1)
  url = sprintf('https://www.billboard.com/charts/year-end/%s/hot-100-artists', i)
  print(url)
  page = read_html(url)
  items = page %>% html_nodes('.ye-chart-item')
  for (j in 1:length(items)) {
    rank = items[j] %>% html_node('.ye-chart-item__rank') %>% html_text() %>% trimws()
    artist = items[j] %>% html_node('.ye-chart-item__title') %>% html_text() %>% trimws()
    datalist[[counter]] = tibble(year = i, rank, artist)
    counter = counter + 1
  }
}

# combine, clean
raw = do.call('rbind', datalist)
billboard = raw %>% mutate(rank = as.integer(rank))

# extract list of artists
billboard %>% group_by(artist) %>% count(sort = T)
billboard_artists = billboard %>% distinct(artist)

# export to .csv file
write_csv(billboard, 'billboard-hot-100-artists-2005to2019.csv')
