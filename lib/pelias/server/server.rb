require 'sinatra'
require 'sinatra/jbuilder'

class Server < Sinatra::Base

  set :show_exceptions, false

  before do
    headers 'Access-Control-Allow-Origin' => '*'
  end

  # Search endpoint
  get '/search' do
    size = params[:size] || 10
    results = Pelias::Search.search(params[:query], params[:viewbox], params[:center], size)
    @hits = results['hits']['hits']
    jbuilder :search
  end

  # Suggest endpoint
  get '/suggest' do
    size = params[:size] || 20
    results = Pelias::Search.suggest(params[:query], size)
    @hits = results['suggestions'][0]['options']
    jbuilder :suggest
  end

  get '/reverse' do
    results = Pelias::Search.reverse_geocode(params[:lng], params[:lat])
    results.to_json
  end

  get '/closest' do
    results = Pelias::Search.closest(params[:lng], params[:lat], params[:type], 1500)
    @hits = results['hits']['hits']
    jbuilder :closest
  end

  # override the default "Sinatra doesn't know this ditty" error page
  error Sinatra::NotFound do
    content_type 'text/plain'
    [404, 'Not Found']
  end

end
