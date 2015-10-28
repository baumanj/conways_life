require "rspec"

# Count the number of 'on' cells surrounding each cell on the board. If the
# number of 'on' cells is less than two, that cell is 'off' for the next
# generation. If the number of 'on' cells is two, that cell stays the same. If
# the number of 'on' cells is three, the cell becomes 'on'. If the number of
# cells is greater than three, the cell becomes 'off'.

describe :succ do
  it "turns a cell 'off' if the number of surrounding 'on' cells is < 2"
  it "leaves a cell unchanged if the number of surrounding 'on' cells == 2"
  it "turns a cell 'on' if the number of surrounding 'on' cells == 3"
  it "turns a cell 'off' if the number of surrounding 'on' cells > 3"
end

def succ
  []
end