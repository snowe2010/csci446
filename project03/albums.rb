#!/usr/bin/env ruby
require 'rack'
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

    sort_order = request.params['order']
    rank_to_highlight = request.params['rank'].to_i

    albums = File.readlines("top_100_albums.txt").each_with_index.map { |record, i| Album.new(i + 1, record) }

    albums.sort! { |l, r| l.send(sort_order.intern) <=> r.send(sort_order.intern) }  # HUGE SECURITY HOLE
    response.write(ERB.new(File.read("list_template.erb")).result(binding))
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

end

Signal.trap('INT') { Rack::Handler::WEBrick.shutdown } # Ctrl-C to quit
Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080
