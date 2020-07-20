### Genres

# define scraper funciton
get_genre_table = function(genre, url) {
  page = read_html(url)
  table = page %>% html_table() %>% first() %>% as_tibble() %>%
    select(subgenre = X3) %>% mutate(genre = genre) %>%
    mutate(rownumber = row_number())
  return(table)
}

# scrape pop, rap, rock, country
pop = get_genre_table('pop', 'http://everynoise.com/everynoise1d.cgi?root=pop&scope=all')
rap = get_genre_table('rap', 'http://everynoise.com/everynoise1d.cgi?root=rap&scope=all')
rock = get_genre_table('rock', 'http://everynoise.com/everynoise1d.cgi?root=rock&scope=all')
country = get_genre_table('country', 'http://everynoise.com/everynoise1d.cgi?root=country&scope=all')

# combine
genres = bind_rows(pop, rap, rock, country) %>% select(genre, subgenre, rownumber)

# evaluate
genres %>% group_by(subgenre) %>% count(sort = T)
genres %>% filter(subgenre == 'country rock')

# import billboard-spotify artist-genre data
url = 'https://raw.githubusercontent.com/erikgregorywebb/billboard/master/data/artist-genres.csv'
artist_genres = read_csv(url) %>% select(artist, genre)

# map subgenres to genres
all_artist_subgenres = artist_genres %>% distinct(genre) %>% pull(genre)
datalist = list()
for (i in 1:length(all_artist_subgenres)) {
  mapped_genre = genres %>% 
    filter(subgenre == all_artist_subgenres[i]) %>%
    arrange(rownumber) %>% pull(genre) %>% first()
  datalist[[i]] = tibble(mapped_genre, mapped_subgenre = all_artist_subgenres[i])
}
all_mapped_genres_subgenres = do.call(rbind, datalist)
all_mapped_genres_subgenres %>% arrange(mapped_genre)

# map subgenres to artists
artist_genres_subgenres = left_join(
  x = artist_genres,
  y = all_mapped_genres_subgenres,
  by = c('genre' = 'mapped_subgenre')
) %>% rename(subgenre = genre, genre = mapped_genre) %>%
  select(artist, genre, subgenre)

# manual overrides
# 'pop rap' -> rap, not pop
# 'pop rock' -> rock, not pop
artist_genres_subgenres = artist_genres_subgenres %>%
  mutate(genre = ifelse(subgenre == 'pop rap', 'rap', ifelse(subgenre == 'pop rock', 'rock', genre)))

# determine single genre for each artist
all_artists = artist_genres_subgenres %>% distinct(artist) %>% pull(artist)
counter = 0
for (i in 1:length(all_artists)) {
  percent_majority = artist_genres_subgenres %>%
    filter(artist == all_artists[i]) %>%
    group_by(genre) %>% count(sort = T) %>% ungroup() %>%
    mutate(percent = n/sum(n)) %>%
    pull(percent) %>% first()
  if(percent_majority <= .5) {
    counter = counter + 1
  }
}
counter / length(all_artists)
