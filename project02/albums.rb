require 'rack'

class AlbumApp

  #requests and responds with stuff
  def call(env)
  	request = Rack::Request.new(env)
  	case request.path
  	when "/form" then render_form request
  	when "/list" then render_list request
    when "/list.css" then render_css
    when "/sd" then exit! 
  	else render_404
  	end
  end

  #build /form page
  def render_form request
  	response = Rack::Response.new
  	File.open("form.html", "rb") { |form| response.write(generate_form form) }
  	response.finish
  end

  #generate html with dynamic options for rank
  def generate_form form
    return_string = ""
    form.each_line do |line|
      if line.include? "<select name=\"rank\" id=\"rank\">"
        return_string += line
        #fragile, but I can fix later if needed. Didn't see the need in this case.
        1.upto(100) { |i| return_string += "<option value=\"#{i}\">#{i}</option>" }
      else
        return_string += line
      end
    end
    return return_string
  end

  #build /list page with different results based on form query
  def render_list request
  	response = Rack::Response.new
    get = request.GET()
    order = get["order"]
    rank = get["rank"]
    #open the list of albums, build a hash of them, and write it to the response
    File.open("top_100_albums.txt", "r") do |form| 
      correct_hash = sort_by order, form
      response.write(convert_to_html correct_hash, order, rank)
    end
  	response.finish
  end

  #call the css for the /list page
  def render_css 
    response = Rack::Response.new([], 200, {"Content-Type" => "text/css"})
    File.open("list.css", "rb") { |css| puts css; response.write(css.read)}
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
    "<!DOCTYPE html>
      <html>
        <title>\"Rolling Stone's Top 100 Albums of All Time\"</title>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"list.css\">
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
      </head>
      <body>
        <h1>Rolling Stone's Top 100 Albums of All Time</h1>
        </br>
        <h3>Sorted by #{order}</h3>
        </br>
        <table>\n" + 
          albums.map do |album| 
            if album[:rank] == rank.to_i
              "<tr id=\"highlighted_row\"> 
                <td>  #{album[:rank]}. </td>
                <td>  #{album[:name]}  </td>
                <td>  #{album[:year]}  </td>
              </tr>" 
            else 
              "<tr>
                <td>  #{album[:rank]}. </td>
                <td>  #{album[:name]}  </td>
                <td>  #{album[:year]}  </td>
              </tr>" 
            end 
          end.join("\n") + 
        "</table>
      </body>
    </html>"
  end

end

#handles ctrl+c shutdown of server
Signal.trap('INT') {
  Rack::Handler::WEBrick.shutdown
}

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080