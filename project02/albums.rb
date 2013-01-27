require 'rack'

class AlbumApp

  def call(env)
  	request = Rack::Request.new(env)
  	case request.path
  	when "/form" then render_form request
  	when "/list" then render_list request
    when "/sd" then exit!
  	else render_404
  	end
    # [200, {"Content-Type" => "text/html"}, ["Hello World"]]
  end

  def render_form request
  	response = Rack::Response.new
  	File.open("form.html", "rb") { |form| response.write(form.read) }
  	response.finish
  end

  def generate_options_list
  end

  def render_list request
  	response = Rack::Response.new
    get = request.GET()
    order = get["order"]
    rank = get["rank"]
    File.open("top_100_albums.txt", "r") do |form| 
      correct_hash = sort_by order, form
      response.write(convert_to_html correct_hash, order, rank)
    end
  	response.finish
  end

  def render_404
  	[404, {"Content-Type" => "text/plain"}, ["Nothing Here"]]
  end

  #This function sorts the albums by the order parameter
  def sort_by order, file
    album_list = create_album_list file
    case order
    when "rank"
      return album_list.sort_by! {|a| a[:rank]}
    when "name"
      return album_list.sort_by! {|a| a[:name]}
    when "year"
      return album_list.sort_by! {|a| a[:year]}
    else render_404
    end
    return album_list
  end

  #Takes in the albums list and splits each line into a hash of rank, name, year and
  #then inserts each row into an array
  def create_album_list file
    albums = []
    rank = 0
    file.each_line do |line|
      ny = Hash.new
      name, year = line.split(",")
      rank += 1
      ny = {  rank: rank, name: name, year: year}
      albums << ny
    end
    return albums
  end

  #Converts the list of albums to html
  def convert_to_html albums, order, rank
    string_before = 
    "<html>
      <head>
        <title>\"Rolling Stone's Top 100 Albums of All Time\"</title>
      </head>
      <body>
        <h1>Rolling Stone's Top 100 Albums of All Time</h1>
        </br>
        <h3>Sorted by #{order}</h3>
        </br>
        <table>\n" + 
          albums.map do |album| 
            puts album[:rank]
            puts rank.to_i
            if album[:rank] == rank.to_i
              "<tr><td  style=\"color: #9829fd\">  #{album[:rank]}. #{album[:name]} #{album[:year]}</td></tr>" 
            else 
              "<tr><td>  #{album[:rank]}. #{album[:name]} #{album[:year]}</td></tr>" 
            end 
          end.join("\n") + 
        "</table>
      </body>
    </html>"
  end

end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080