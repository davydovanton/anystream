# anystream_routers.rb
Application = Anysctream::App.new do
  consumer_group :test do
    topic :created do
      consumer ConsumerClass
      batch_consuming true
    end

    topic :updated do
      consumer ConsumerClass
    end
  end
end

# anystream_redis.rb
coinfig = {
  host: ...,
  logger: ...,
  ...
}

instance = Anysctream.new(:adapter, Application, config)
Anystream::Server.new(instance).boot!
