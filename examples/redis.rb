require 'redis'

if ARGV.length == 0
  puts "Please specify a consumer name"
  exit 1
end

ConsumerName = ARGV[0]
GroupName = "mygroup"
r = Redis.new

def process_message(id,msg)
  puts "[#{ConsumerName}] #{id} = #{msg.inspect}"
end

$lastid = '0-0'

puts "Consumer #{ConsumerName} starting..."
check_backlog = true
while true
  # Pick the ID based on the iteration: the first time we want to
  # read our pending messages, in case we crashed and are recovering.
  # Once we consumer our history, we can start getting new messages.
  if check_backlog
    myid = $lastid
  else
    myid = '>'
  end

  items = r.xreadgroup('GROUP',GroupName,ConsumerName,'BLOCK','2000','COUNT','10','STREAMS',:my_stream_key,myid)

  if items == nil
    puts "Timeout!"
    next
  end

  # If we receive an empty reply, it means we were consuming our history
  # and that the history is now empty. Let's start to consume new messages.
  check_backlog = false if items[0][1].length == 0

  items[0][1].each{|i|
    id,fields = i

    # Process the message
    process_message(id,fields)

    # Acknowledge the message as processed
    r.xack(:my_stream_key,GroupName,id)

    $lastid = id
  }
end
