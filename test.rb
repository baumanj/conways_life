require "rspec"

require "./life"

if __FILE__ == $0
  puts `rspec -f documentation #{__FILE__}`
end

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
