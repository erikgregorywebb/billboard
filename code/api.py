### authenticate
import spotipy
import spotipy.util as util

username = '1268341921'
scope = 'user-library-read'
client_id = 'CLIENT-ID-HERE'
client_secret = 'CLIENT-SECRET-HERE'
redirect_uri = 'https://example.com/callback'

token = util.prompt_for_user_token(
        username = username,
        scope = scope,
        client_id = client_id,
        client_secret = client_secret,
        redirect_uri = redirect_uri)

spotify = spotipy.Spotify(auth=token)

### define function
def spotify_artist(artist_name):
    results = spotify.search(q='artist:' + artist_name, type='artist')
    items = results['artists']['items']
    if len(items) > 0:
        artist = items[0]
        #print(artist['name'], artist['images'][0]['url'], artist['id'])
        return(artist)
    else:
        return('No artist found')
        
### demo function
artist_name = 'drake'
spotify_artist(artist_name)

### import billboard data
import pandas as pd
import time
url = 'https://raw.githubusercontent.com/erikgregorywebb/datasets/master/billboard-hot-100-artists-2005to2019.csv'
billboard = pd.read_csv(url)
billboard_artists = billboard.artist.unique()
billboard_artists[0]

### loop over artists
rows = []
for artist in billboard_artists:
    time.sleep(1)
    try:
        s_artist = spotify_artist(artist)
        row = [artist, s_artist['name'], s_artist['id'], s_artist['href'],
              s_artist['followers'], s_artist['genres'], s_artist['popularity'],
              s_artist['images'][0]['url']]
        #print('Success: ', artist, s_artist['name'])
    except:
        row = [artist, '', '', '', '', '', '', '',]
        #print('Failure: ', artist)
    rows.append(row)
    
all_artists = pd.DataFrame(rows, columns = ('artist', 'spotify_artist', 'id', 'href', 'followers', 'genres', 'popularity', 'image'))
all_artists.head(1)

### unnest genres
artist_genres = all_artists.set_index('artist').genres.apply(pd.Series).stack().reset_index(level=0).rename(columns={0:'genre'})
artist_details = all_artists.drop(['followers', 'genres'], axis=1)

### export
artist_genres.to_csv('artist-genres.csv')
artist_details.to_csv('artist-details.csv')
