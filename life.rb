require "rspec"

# Count the number of 'on' cells surrounding each cell on the board. If the
# number of 'on' cells is less than two, that cell is 'off' for the next
# generation. If the number of 'on' cells is two, that cell stays the same. If
# the number of 'on' cells is three, the cell becomes 'on'. If the number of
# cells is greater than three, the cell becomes 'off'.

Cell = Struct.new(:row, :col)
LOW_THRESHOLD = 2
HIGH_THRESHOLD = 3
MAX_GRID_SIZE = 1_000_000

describe :succ do
  test_cell = Cell.new(rand(MAX_GRID_SIZE), rand(MAX_GRID_SIZE))

  it "turns a cell 'off' if the number of surrounding 'on' cells is < LOW_THRESHOLD" do

    (0...LOW_THRESHOLD).each do |num_surrounding|
      on_cells = [test_cell] + surrounding_cells(test_cell).sample(num_surrounding)
      expect(send(subject, on_cells)).to_not include(test_cell)
    end
  end

  it "leaves a cell unchanged if the number of surrounding 'on' cells == LOW_THRESHOLD" do
    on_cells = surrounding_cells(test_cell).sample(LOW_THRESHOLD)

    expect(send(subject, [test_cell] + on_cells)).to include(test_cell)
    expect(send(subject, on_cells)).to_not include(test_cell)
  end

  it "turns a cell 'on' if the number of surrounding 'on' cells == HIGH_THRESHOLD" do
    on_cells = surrounding_cells(test_cell).sample(HIGH_THRESHOLD)

    expect(send(subject, on_cells)).to include(test_cell)
  end

  it "turns a cell 'off' if the number of surrounding 'on' cells > HIGH_THRESHOLD" do
    surrounding_cells = surrounding_cells(test_cell).sample(HIGH_THRESHOLD)

    (HIGH_THRESHOLD..surrounding_cells.size).each do |num_surrounding|
      on_cells = [test_cell] + surrounding_cells.sample(num_surrounding)
      expect(send(subject, on_cells)).to_not include(test_cell)
    end
  end
end

def succ(on_cells)
  nil
end

def surrounding_cells(cell)
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

  sorted_on_cells = on_cells.map {|c| Cell.new(*c) }.sort_by(&:col).sort_by(&:row)
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