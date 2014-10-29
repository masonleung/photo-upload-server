require 'bunny'

class ImageQueue
  def initialize
    conn = Bunny.new
    conn.start
    @qname = 'images_upload'
    ch = conn.create_channel
    @q = ch.queue(@qname, :durable => true)
    @x = ch.default_exchange
  end

  def enqueue message
    @x.publish(message, :routing_key => @qname)
  end

  def dequeue
    delivery_info, properties, payload = @q.pop
    payload
  end
end