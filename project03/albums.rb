#!/usr/bin/env ruby
require 'rack'
require 'sqlite3'
require_relative 'album'

class AlbumApp
  def call(env)
    request = Rack::Request.new(env)
    case request.path
    when "/form" then render_form(request)
    when "/list" then render_list(request)
    else render_404
    end
  end

  def render_form(request)
    response = Rack::Response.new
    response.write(ERB.new(File.read("form_template.erb")).result(binding))
    response.finish
  end

  def render_list(request)
    response = Rack::Response.new

    begin
      db = SQLite3::Database.new("albums.sqlite3.db")
      databasealbums = db.execute("select * from albums")
    rescue SQLite3::Exception => e
      puts "exception occured"
      puts e
    ensure
      db.close if db
    end

    sort_order = request.params['order']
    rank_to_highlight = request.params['rank'].to_i

    #map each column to an attribute of an Album
    albums = databasealbums.each.map { |id, title, year, rank| Album.new(id, title, year, rank) }

    albums.sort_by! {|album| album.send(sort_order.to_sym)}

    response.write(ERB.new(File.read("list_template.erb")).result(binding))
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

end

Signal.trap('INT') { Rack::Handler::WEBrick.shutdown } # Ctrl-C to quit
Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080
