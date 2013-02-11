require 'sinatra'
require 'data_mapper'
require_relative 'album'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")

set :port, 8080

get "/" do
	redirect '/form'
end

get "/form" do
	erb :form
end

get "/list" do
	@albums = Album.all
	@rank_to_highlight = params[:rank].to_i
	@sort_order = params[:order]
	erb :list
end
