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

class Recreation
  def initialize(label, opening_hours, reservations_per_user=1)
    @label = label
    @opening_hours = opening_hours.clone.freeze
    @reservations_per_user = reservations_per_user || 1
    @reservations = {}
  end

  def reserve(name, hour)
    reservations_made = @reservations.values.select {|reservation| reservation == name}
    if reservations_made.length < @reservations_per_user
      if @reservations[hour].nil?
        @reservations[hour] = name
      else
        raise ReservationException.new("Ouch! Someone has made a reservation on this time in this moment.")
      end
    else
      raise ReservationException.new("You have already made a maximum number of reservation today.")
    end
  end
  
  def cancel(name, hour)
    if name == @reservations[hour]
      @reservations[hour] = nil
    else
      raise ReservationException.new("You've tried to cancel someone's else reservation!")
    end
  end
  
  def label
    @label
  end
  
  def reservations    
    Marshal::load(Marshal.dump(@reservations)).freeze
  end
  
  def opening_hours
    @opening_hours
  end
  
  class ReservationException < Exception
  end
end

class RecreationFactory
  def self.create(label, hours, minutes, max_per_user=nil)
    opening_hours = (hours.map {|h| minutes.map {|m| h.to_s+":"+m.to_s}}).flatten
    Recreation.new(label, opening_hours, max_per_user)
  end
end

today = nil
reservations = []
name = ""

before do
  if today != Date.today
    foosball = RecreationFactory.create("Foosball", (8..16), ["00", "30"])
    billard = RecreationFactory.create("Billard", (8..16), %w[00 15 30 45], 2)
    reservations = [foosball, billard]
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
    flash[:notice] = "Reservation made."
  rescue Recreation::ReservationException => e
    flash[:error] = e.message
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
    flash[:error] = "The application badly behaved :(."
  end
  redirect to('/')
end

post '/cancel' do
  begin
    reservation_id = params[:id] or raise "No reservation ID!"
    reservations[reservation_id.to_i].cancel(name, params[:time])
    flash[:notice] = "Reservation canceled."
  rescue Recreation::ReservationException => e
    flash[:error] = e.message
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
    flash[:error] = "The application badly behaved :(."
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
                      %td= time
                      %td
                        - if reservations[time].nil?
                          %form{:action => '/reserve', :method => :post}
                            %input{:type => :hidden, :name => 'id', :value => index}
                            %input{:type => :hidden, :name => 'time', :value => time}
                            %input{:type => :submit, :value => "Reserve"}
                        - else
                          = reservations[time]
                          - if reservations[time] == name
                            %form.cancel{:action => '/cancel', :method => :post}
                              %input{:type => :hidden, :name => 'id', :value => index}
                              %input{:type => :hidden, :name => 'time', :value => time}
                              %button{:type => :submit}
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
