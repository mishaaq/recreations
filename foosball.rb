
require 'date'
require 'sinatra'
require 'rack-flash'
require 'haml'
require 'sass'
enable :sessions

use Rack::Flash

today = nil
times = %w[8:00 8:30 9:00 9:30 10:00 10:30 11:00 11:30 12:00 12:30 13:00 13:30 14:00 14:30 15:00 15:30 16:00 16:30 17:00]

reservations = nil
ips = nil

before do
  if today != Date.today
    reservations = Hash[times.zip([nil])]
    ips = []
    today = Date.today
  end
end

get '/' do
  available = times.select { |time| reservations[time].nil? }
  haml :index, :locals => { :times => times, :available => available, :reservations => reservations,
                            :notice => flash[:notice], :error => flash[:error] }
end

post '/' do
  unless ips.include?(request.ip)
    if reservations[params[:time]].nil?
      reservations[params[:time]] = params[:name]
      # ips << request.ip
      flash[:notice] = "Reservation made."
    else
      flash[:error] = "Ouch! Someone has made a reservation on this time in this moment."
    end
  else
    flash[:error] = "You have already made a reservation today."
  end
  redirect to('/')
end

get '/stylesheet.css' do
  sass :stylesheet
end

__END__

@@ layout
!!! XML
!!!
%html(xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en")
  %head
    %title= "Foosball"
    %link{:rel => "stylesheet", :href => "/stylesheet.css", :type => "text/css"}
  %body
    = yield


@@ index
%div.top
  - if notice
    %p.notice= notice
  - if error
    %p.error= error
%div.left
  %table
    %thead
      %tr
        %td Hour
        %td Occupied
    %tbody
      - times.each do |time|
        %tr
          %td= time
          %td= reservations[time]

%div.right
  %form{:action => '/', :method => :post}
    My name is
    %input{:type => :text, :name => "name"}
    and I would like to make a reservation of the foosball table on
    %select{:name => "time"}
      - available.each do |time|
        %option= time.nil? ? "free" : time
    %input{:type => :submit, :value => "Reserve"}


@@ stylesheet
div.top
  width: 100%
  margin: 10px
  
div.left
  float: left
  margin: 10px
  
div.right
  float: right
  margin: 10px
