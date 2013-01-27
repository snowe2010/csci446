require 'rack'

class AlbumApp

  def call(env)
  	request = Rack::Request.new(env)
  	case request.path
  	when "/form" then render_form request
  	when "/list" then render_list request
  	else render_404
  	end
    # [200, {"Content-Type" => "text/html"}, ["Hello World"]]
  end

  def render_form request
  	response = Rack::Response.new
  	File.open("form.html", "rb") { |form| response.write(form.read) }
  	response.finish
  end

  def render_list request
  	response = Rack::Response.new request.path
    get = request.GET()
    order = get["order"]
    rank = get["rank"]
    File.open("top_100_albums.txt", "r") do |form| 
      correct_hash = sort_by order, rank, form
      response.write(convert_to_html correct_hash, order)
    end
  	response.finish
  end

  def render_404
  	[404, {"Content-Type" => "text/plain"}, ["Nothing Here"]]
  end

  def sort_by order, rank, file
    album_list = create_album_list file
    case order
    when "rank"
      return album_list
    when "name"
      return album_list.sort_by! {|a| a[:name]}
    when "year"

    else render_404
    end
    return album_list
  end

  def create_album_list file
    albums = []
    
    file.each_line do |line|
      ny = Hash.new
      name, year = line.split(",")
      
      ny = { name: name, year: year}
      albums << ny
    end
    return albums
  end

  def convert_to_html albums, order
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
          albums.map { |album| "<tr><td> #{album[:name]} year is: #{album[:year]}</td></tr>" }.join("\n") + 
        "</table>
      </body>
    </html>"
  end

end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080