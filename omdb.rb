require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'
require 'pry'

# create a simple class to store movie title, year, and id
class Movie
    attr_accessor :title, :year, :id

    def initialize(new_title="", new_year="", new_id="")
      @title = new_title
      @year = new_year
      @id = new_id
    end
end


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
  result_hash["Search"].each { |h| movie_list << Movie.new(h["Title"], h["Year"], h["imdbID"]) }

  # Modify the html output so that a list of movies is provided. (includes a link to each movie's poster, based on id)
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  movie_list.each { |movie| html_str += "<li><a href='/poster/#{movie.id}'>#{movie.title} - #{movie.year}</a></li>" }
  html_str += "</ul></body></html>"

end

get '/poster/:imdb_id' do |imdb_id|
  # Make another api call here to get the url of the poster.
  response = Typhoeus.get("www.omdbapi.com", :params => {:i => imdb_id})

  # store result in a hash, for better parsing
  result_hash = JSON.parse(response.body)

  # extract the poster URL
  poster_url = result_hash["Poster"]
  

  # Display the simple page with the poster
  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str += "<h3>Movie ID: #{imdb_id}</h3>"
  html_str += "<img src='#{poster_url}'/><br/>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

