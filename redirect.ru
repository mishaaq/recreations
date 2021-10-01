#\ -p 80

app = proc do |env|
  request = Rack::Request.new(env)
  url = request.url.gsub(/^http/, 'https')
  [301, {'Location' => url, 'Content-Type' => 'text/html'}, ['']]
end

run app