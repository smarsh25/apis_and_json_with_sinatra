require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'
require 'pry'


#
# Create and display (on get) original movie search page / form
#
get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
  </form></body></html>
  )
end

post '/result' do
  search_str = params[:movie]

  # Create a request to OMDB API, search (param is 's') for movie titles
  response = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})

  # store result in a hash, for better parsing
  result_hash = JSON.parse(response.body)

  movie_list = []
  result_hash["Search"].each { |h| movie_list.push("#{h["Title"]} - #{h["Year"]}")}
  # binding.pry

  # Modify the html output so that a list of movies is provided.
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  movie_list.each { |movie| html_str += "<li>#{movie}</li>" }
  html_str += "</ul></body></html>"

end

get '/poster/:imdb' do |imdb_id|
  # Make another api call here to get the url of the poster.
  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str = "<h3>#{imdb_id}</h3>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

