require 'rubygems'
require 'date'
require 'sinatra'
require 'rack-flash'
require 'haml'
require 'sass'
require 'resolv'

set :public, File.dirname(__FILE__) + '/static'
enable :sessions

use Rack::Flash

resolv = Resolv.new

today = nil
times = %w[8:00 8:30 9:00 9:30 10:00 10:30 11:00 11:30 12:00 12:30 13:00 13:30 14:00 14:30 15:00 15:30 16:00 16:30 17:00]

reservations = nil

before do
  if today != Date.today
    reservations = Hash[times.zip([nil])]
    today = Date.today
  end
end

get '/' do
  available = times.select { |time| reservations[time].nil? }
  haml :index, :locals => { :times => times, :available => available, :reservations => reservations,
                            :notice => flash[:notice], :error => flash[:error] }
end

post '/' do
  name = resolv.getname(request.ip)
  unless reservations.has_value?(name)
    if reservations[params[:time]].nil?
      reservations[params[:time]] = name
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
    %div.notice
      %p= notice
  - if error
    %div.error
      %p= error
%div.table
  %table
    %thead
      %tr
        %th Hour
        %th Occupied
    %tbody
      - times.each do |time|
        %tr
          %td= time
          %td
            - if reservations[time].nil?
              %form{:action => '/', :method => :post}
                %input{:type => :hidden, :name => 'time', :value => time}
                %input{:type => :submit, :value => "Reserve"}
            - else
              = reservations[time]

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
  
.table
  margin: 20px
  float: left

table
  border-color: gray
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