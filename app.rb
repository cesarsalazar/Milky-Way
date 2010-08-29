
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations' 
require 'dm-timestamps'
require 'syntaxi'
require 'haml'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/milky-way.sqlite3")

class Snippet
  include DataMapper::Resource

  property :id,         Serial   
  property :body,       Text,    :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  Syntaxi.line_number_method = 'floating'
  Syntaxi.wrap_at_column = 60

  def formatted_body
    replacer = Time.now.strftime('[code-%d]')
    html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]', replacer)}[/code]").process
    "<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, '[/code]')}</div>"
  end
end

DataMapper.auto_upgrade!

# new
get '/' do
  haml :new
end

# create
post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body])
  if @snippet.save
    redirect "/show/#{@snippet.id}"
  else
    redirect '/'
  end
end

# show
get '/show/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    haml :show
  else
    redirect '/'
  end
end

# global.css
get '/global.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :global
end
