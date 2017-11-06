Recreations
========

Overview
--------

This is simple application to make reservations of something for a specified time.
It might help stop fighting for the soccer table in a company :).

It's built upon Padrino (padrinorb.com)

Installation
-------

It uses bundler to manage required gems, so there are few steps needed to settle everything down:


    git clone https://github.com/mishaaq/recreations.git
    cd recreations
    bundle install
    RACK_ENV=production bundle exec rake db:create db:migrate db:seed

Loading
-------

Run the server:

    RACK_ENV=production rackup config.ru
