Recreations
========

Overview
--------

This is simple application to make reservations of something for a specified time.
It might help stop fighting for the soccer table in a company :).

Using gems:

* sinatra,
* haml,
* sass,
* rack-flash


Configuration
-------

Sample recreations are defined in recreations.yml. Please specify your ones:

  * key - the name of a recreation
  * time - range of hours for whom the reservation could be made
  * interval - amount of time for one reservation
  * max_per_user - maximal number of reservations that could be made by one user
  
Loading
-------

    ruby app.rb
