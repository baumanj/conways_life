require "rspec"

# Count the number of 'on' cells surrounding each cell on the board. If the
# number of 'on' cells is less than two, that cell is 'off' for the next
# generation. If the number of 'on' cells is two, that cell stays the same. If
# the number of 'on' cells is three, the cell becomes 'on'. If the number of
# cells is greater than three, the cell becomes 'off'.

Cell = Struct.new(:row, :col)

describe :succ do
  it "turns a cell 'off' if the number of surrounding 'on' cells is < 2" do
    on_cell = Cell.new(1, 1) # use rand

    (0...2).each do |num_surrounding|
      on_cells = [on_cell] + surrounding_cells(on_cell).sample(num_surrounding)
      expect(send(subject, on_cells)).to be_empty
    end
  end

  it "leaves a cell unchanged if the number of surrounding 'on' cells == 2"
  it "turns a cell 'on' if the number of surrounding 'on' cells == 3"
  it "turns a cell 'off' if the number of surrounding 'on' cells > 3"
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