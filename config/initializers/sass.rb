module SassInitializer
  def self.registered(app)
    # Enables support for SASS template reloading in rack applications.
    # See http://nex-3.com/posts/88-sass-supports-rack for more details.
    # Store SASS files (by default) within 'app/stylesheets'.
    require 'sass/plugin/rack'
    Sass::Plugin.options[:syntax] = :scss
    Sass::Plugin.add_template_location(app.root + '/stylesheets', app.public_folder + '/stylesheets')
    app.use Sass::Plugin::Rack
  end
end
