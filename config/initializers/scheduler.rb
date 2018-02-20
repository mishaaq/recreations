module SchedulerInitializer
  def self.registered(app)
    require 'rufus-scheduler'
    app.class.__send__(:attr_accessor, "scheduler")
    app.__send__("scheduler=", Rufus::Scheduler.new({:frequency => '1m'}))
    app
  end
end