class TestLogger < Logger
  def initialize
    @io = StringIO.new
    super(@io)
  end

  def messages
    @io.string
  end
end
