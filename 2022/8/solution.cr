require "../helper"

sample = <<-TEXT
30373
25512
65332
33549
35390
TEXT

def tree_counter(data)
  matrix = data.lines.map(&.chars.map(&.to_i))

  visible_trees = [] of {Int32, Int32}

  matrix.each.with_index do |row, i|
    current_height = row[0]
    visible_trees << {i, 0}

    row.each.with_index do |height, j|
      if height > current_height
        visible_trees << {i, j}
        current_height = height
      end
    end

    current_height = row[-1]
    visible_trees << {i, row.size - 1}

    row.reverse.each.with_index do |height, j|
      if height > current_height
        visible_trees << {i, row.size - j - 1}
        current_height = height
      end
    end
  end

  matrix.transpose.each.with_index do |row, i|
    current_height = row[0]
    visible_trees << {0, i}

    row.each.with_index do |height, j|
      if height > current_height
        visible_trees << {j, i}
        current_height = height
      end
    end

    current_height = row[-1]
    visible_trees << {row.size - 1, i}

    row.reverse.each.with_index do |height, j|
      if height > current_height
        visible_trees << {row.size - j - 1, i}
        current_height = height
      end
    end
  end

  visible_trees.uniq.size
end

AOC(Int32)["visible trees"].do do
  assert_equal 21, tree_counter(sample)

  solve do
    solution tree_counter(input)
  end
end

def scenic_score(data)
  matrix = data.lines.map(&.chars.map(&.to_i))
  matrix_size = matrix.size - 1

  scenic_score = Array(Int32).new(matrix_size + 1, 0).map { Array(Int32).new(matrix_size + 1, 0) }

  matrix.each.with_index do |row, i|
    row.each.with_index do |height, j|
      viewing_distance = Array.new(4, 0)
      current_height = height

      (i-1).downto(0) do |i_2|
        viewing_distance[0] += 1
        break if matrix[i_2][j] >= height
      end

      (i+1).upto(matrix_size) do |i_2|
        viewing_distance[1] += 1
        break if matrix[i_2][j] >= height
      end

      (j-1).downto(0) do |j_2|
        viewing_distance[2] += 1
        break if matrix[i][j_2] >= height
      end

      (j+1).upto(matrix_size) do |j_2|
        viewing_distance[3] += 1
        break if matrix[i][j_2] >= height
      end

      scenic_score[i][j] = viewing_distance.product
    end
  end

  scenic_score.flatten.max
end

AOC(Int32)["scene score"].do do
  assert_equal 8, scenic_score(sample)

  solve do
    solution scenic_score(input)
  end
end
