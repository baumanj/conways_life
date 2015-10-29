require "rspec"
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

Cell = Struct.new(:row, :col) do
  def to_s
    "[#{row},#{col}]"
  end

  def <=> other
    row == other.row ? col <=> other.col : row <=> other.row
  end
end

LOW_THRESHOLD = 2
HIGH_THRESHOLD = 3
MAX_GRID_SIZE = 1_000_000

describe :succ do
  1000.times do
    test_cell = Cell.new(rand(MAX_GRID_SIZE), rand(MAX_GRID_SIZE))

    it "turns a cell 'off' if the number of surrounding 'on' cells is < LOW_THRESHOLD" do

      (0...LOW_THRESHOLD).each do |num_surrounding|
        on_cells = [test_cell] + neighbors(test_cell).sample(num_surrounding)
        expect(send(subject, on_cells)).to_not include(test_cell)
      end
    end

    it "leaves a cell unchanged if the number of surrounding 'on' cells == LOW_THRESHOLD" do
      on_cells = neighbors(test_cell).sample(LOW_THRESHOLD)

      expect(send(subject, [test_cell] + on_cells)).to include(test_cell)
      expect(send(subject, on_cells)).to_not include(test_cell)
    end

    it "turns a cell 'on' if the number of surrounding 'on' cells == HIGH_THRESHOLD" do
      on_cells = neighbors(test_cell).sample(HIGH_THRESHOLD)

      expect(send(subject, on_cells)).to include(test_cell)
    end

    it "turns a cell 'off' if the number of surrounding 'on' cells > HIGH_THRESHOLD" do
      neighbors = neighbors(test_cell).sample(HIGH_THRESHOLD)

      ((HIGH_THRESHOLD + 1)..neighbors.size).each do |num_surrounding|
        on_cells = [test_cell] + neighbors.sample(num_surrounding)
        expect(send(subject, on_cells)).to_not include(test_cell)
      end
    end
  end
end

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
  offsets.product(offsets).reject {|x| x == [0,0] }.map do |ro, co|
    Cell.new(cell.row + ro, cell.col + co)
  end
end

def print_board(on_cells)
  if on_cells.empty?
    puts "No 'on' cells"
    return
  end

  sorted_on_cells = on_cells.map {|c| Cell.new(*c) }.sort
  row_range = (sorted_on_cells.first.row)..(sorted_on_cells.last.row)
  col_range = (sorted_on_cells.first.col)..(sorted_on_cells.last.col)
  puts "Printing [#{row_range.begin}, #{col_range.begin}]..[#{row_range.end}, #{col_range.end}]"
  row_range.each do |r|
    col_range.each do |c|
      print sorted_on_cells.include?(Cell.new(r, c)) ? "█" : " "
    end
    puts "…"
  end
end

handle_succ = proc do
  # puts "params: #{params.inspect}"
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
