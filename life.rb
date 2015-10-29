require "set"
require "sinatra"

# Count the number of 'on' cells surrounding each cell on the board. If the
# number of 'on' cells is less than two, that cell is 'off' for the next
# generation. If the number of 'on' cells is two, that cell stays the same. If
# the number of 'on' cells is three, the cell becomes 'on'. If the number of
# cells is greater than three, the cell becomes 'off'.

# Resources used:
# * http://json-p.org
# * http://api.jquery.com/jquery.ajax/
# * http://www.w3schools.com
# * http://www.sinatrarb.com
# * http://snippets.aktagon.com/snippets/445-how-to-create-a-jsonp-cross-domain-webservice-with-sinatra-and-ruby
# * http://www.sitepoint.com/get-started-with-sinatra-on-heroku/

Cell = Struct.new(:x, :y) do
  def to_s
    "[#{x},#{y}]"
  end

  def <=> other
    x == other.x ? y <=> other.y : x <=> other.x
  end
end

LOW_THRESHOLD = 2
HIGH_THRESHOLD = 3

def succ(on_cells)
  cells_to_consider =
    Set.new(on_cells)
    .union(on_cells.flat_map {|c| neighbors(c) })
  next_generation = Set.new

  cells_to_consider.each do |c|
    num_on_neighbors = (neighbors(c) & on_cells).size
    case num_on_neighbors
    when LOW_THRESHOLD
      next_generation << c if on_cells.include?(c)
    when HIGH_THRESHOLD
      next_generation << c
    end
  end

  next_generation
end

def neighbors(cell)
  offsets = [-1, 0, +1]
  offsets.product(offsets).reject {|x| x == [0,0] }.map do |xo, yo|
    Cell.new(cell.x + xo, cell.y + yo)
  end
end

handle_succ = proc do
  live_cells = params.fetch('liveCells', {}).values.map do |int_strings|
    Cell.new(*int_strings.map {|s| Integer(s) })
  end
  next_generation = succ(live_cells).sort
  json = "[#{next_generation.map(&:to_s).join(',')}]"
  if params.key?('callback')
    content_type :js
    "#{params['callback']}(#{json})"
  else
    content_type :json
    json
  end
end

get('/succ', &handle_succ)
post('/succ', &handle_succ)

get '/' do
  erb :index
end

get '/jsonp' do
  erb :index, locals: {jsonp: true}
end
