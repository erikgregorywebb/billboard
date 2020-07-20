
library(tidyverse)
library(scales)
library(viridis)

# import billboard hot artist rankings
url = 'https://raw.githubusercontent.com/erikgregorywebb/billboard/master/data/billboard-hot-100-artists-2005to2019.csv'
billboard = read_csv(url)

# import artist genres
url = 'https://raw.githubusercontent.com/erikgregorywebb/billboard/master/data/artist-main-genre.csv'
artist_main_genre = read_csv(url)

# merge datasets
billboard = left_join(
  x = billboard,
  y = artist_main_genre,
  by = 'artist'
) 

# fill in gaps?
billboard %>% filter(is.na(genre) == T) %>% distinct(artist)

# calculate genre breakdown by year
billboard_trend = billboard %>%
  group_by(year, genre) %>%
  count() %>% spread(genre, n) %>%
  mutate(total = country + pop + rap + rock) %>%
  mutate(pop_per = pop / total, rap_per = rap / total, 
         rock_per = rock / total, country_per = country / total) %>%
  select(year, pop_per, rap_per, rock_per, country_per) %>%
  rename(Pop = pop_per, Rap = rap_per, Rock = rock_per, Country = country_per, Year = year) %>%
  gather(genre, percent, -Year) %>% rename(Genre = genre, Percent = percent)

# plot
billboard_trend %>%
  filter(Year != 2005) %>% # filter out erroneous year 
  mutate(Genre = factor(Genre, levels = c('Pop', 'Rap', 'Country', 'Rock'))) %>%
  ggplot(., aes(x = Year, y = Percent, fill = Genre)) + 
  geom_area(alpha = .8 , size = .5, colour = 'white') + 
  scale_fill_viridis(discrete = T) + 
  scale_y_continuous(labels = percent) + 
  #scale_x_discrete(labels = seq(from = 2005, to = 2019, by = 1)) +  
  labs(title = 'Trend in Music Genre Popularity, 2006 - Present', 
       subtitle = 'Measured by % of Billboard Hot 100 Artists in each genre',
       caption = 'Source: Billboard, Spotify, Every Noise | Author: @erikgregorywebb',
       y = '% of Artists within Genre', x = '') + 
  theme_minimal() +
  theme(legend.position = 'top') + theme(text = element_text(size = 15))

# export
totals = billboard %>%
  group_by(year, genre) %>%
  count() %>% spread(genre, n) %>%
  mutate(total = country + pop + rap + rock) %>%
  mutate(pop_per = pop / total, rap_per = rap / total, 
         rock_per = rock / total, country_per = country / total) %>%
  select(year, pop_per, rap_per, rock_per, country_per) %>%
  rename(Pop = pop_per, Rap = rap_per, Rock = rock_per, Country = country_per, Year = year)
write_csv(totals, 'genre-percent-breakdown-by-year.csv')
