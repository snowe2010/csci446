class Album

  attr_accessor :rank, :title, :year

  def initialize(rank, raw_string)
    @rank = rank
    @title, raw_year = raw_string.split(',')
    @year = raw_year[/\d+/].to_i
  end

end