class Album

  attr_accessor :id, :rank, :title, :year

  def initialize(id, title, year, rank)
    @rank = rank
    @title, @year = title, year
    @id = id
    # @year = raw_year[/\d+/].to_i
  end

end
