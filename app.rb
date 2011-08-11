require 'rubygems'
require 'date'
require 'time'
require 'yaml'
require 'sinatra'
require 'rack-flash'
require 'haml'
require 'sass'
require 'resolv'

require 'recreation'

set :public, File.dirname(__FILE__) + '/static'
enable :sessions

use Rack::Flash

resolv = Resolv.new

$localize = {
  :"reserve-in-past" => "Cannot reserve a time in the past.",
  :"max-reservations" => "You have already made a maximum number of reservations today.",
  :"reservation-occupied" => "Ouch! Someone has made a reservation on this time in this moment.",
  :"cancel-in-past" => "Cannot cancel a reservation in the past.",
  :"cannot-cancel" => "You've tried to cancel someone's else reservation!",
  :"reservation-made" => "Reservation made.",
  :"reservation-canceled" => "Reservation canceled.",
  :"exception-occured" => "The application badly behaved :(."
}

today = nil
reservations = []
name = ""
games = YAML.load_file('recreations.yml')

before do
  if today != Date.today
    reservations = games.keys.map do |game|
      gm = games[game]
      RecreationFactory.create(game.gsub("_", " ").capitalize,
                               gm["time"], gm["interval"], gm["max_per_user"])
    end
    today = Date.today
  end
  name = resolv.getname(request.ip).split('.').first
  name = request.host if name == 'localhost'
end

get '/' do
  haml :index, :locals => { :recreations => reservations, :name => name,
                            :notice => flash[:notice], :error => flash[:error] }
end

post '/reserve' do
  begin
    reservation_id = params[:id] or raise "No reservation ID!"
    reservations[reservation_id.to_i].reserve(name, params[:time])
    flash[:notice] = $localize[:"reservation-made"]
  rescue Recreation::ReservationException => e
    flash[:error] = e.message
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
    flash[:error] = $localize[:"exception-occured"]
  end
  redirect to('/')
end

post '/cancel' do
  begin
    reservation_id = params[:id] or raise "No reservation ID!"
    reservations[reservation_id.to_i].cancel(name, params[:time])
    flash[:notice] = $localize[:"reservation-canceled"]
  rescue Recreation::ReservationException => e
    flash[:error] = e.message
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
    flash[:error] = $localize[:"exception-occured"]
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
    %title= "Recreations"
    %link{:rel => "stylesheet", :href => "/stylesheet.css", :type => "text/css"}
  %body
    = yield

@@ index
%div.top
  - if notice
    %div.notice
      %p= notice
  - if error
    %div.error
      %p= error
%div.tables
  %table
    %thead
      %tr
        - recreations.each do |recreation|
          %td.label= recreation.label.capitalize
    %tbody
      %tr
        - recreations.each_with_index do |recreation, index|
          - reservations = recreation.reservations
          %td.recreation
            - recreation.opening_hours.each_slice(18) do |time_slice|
              %table.recreation
                %thead
                  %tr
                    %th Hour
                    %th Occupied
                %tbody
                  - time_slice.each do |time|
                    %tr
                      %td= time.strftime("%H:%M")
                      - disabled = time < Time.now
                      %td
                        - if reservations[time].nil?
                          %form{:action => '/reserve', :method => :post}
                            %input{:type => :hidden, :name => 'id', :value => index}
                            %input{:type => :hidden, :name => 'time', :value => time.strftime("%H:%M")}
                            %input{:type => :submit, :value => "Reserve", :disabled => disabled}
                        - else
                          = reservations[time]
                          - if reservations[time] == name
                            %form.cancel{:action => '/cancel', :method => :post}
                              %input{:type => :hidden, :name => 'id', :value => index}
                              %input{:type => :hidden, :name => 'time', :value => time.strftime("%H:%M")}
                              %button{:type => :submit, :disabled => disabled}
                                %img{:src => "/cross.png"}

%div.graphic
  %img{:src => "/table.jpg"}

@@ stylesheet
.top
  width: 45%
  margin: 20px
  p
    padding: 8px
  div
    border-radius: 5px
    &.notice
      background-color: #66FF33
    &.error
      background-color: red
  
.tables
  margin: 20px
  float: left
  
table
  td.recreation
    vertical-align: top
    padding: 5px
  td.label
    text-align: center
    font-weight: bold

table.recreation
  display: inline-table
  border-color: gray
  vertical-align: top
  th
    vertical-align: middle
    background-color: #B9C9FE
    &:first-child
      border-top-left-radius: 8px
      min-width: 60px
    &:last-child
      border-top-right-radius: 8px

  tr
    td
      background-color: #E8EDFF
      color: #669
      padding: 8px
    &:hover
      td
        background-color: #D0DAFD
    &:last-child
      td
        &:first-child
          border-bottom-left-radius: 8px
        &:last-child
          border-bottom-right-radius: 8px

.graphic
  float: right
  margin: 20px

form.cancel
  display: inline

button
  width: auto