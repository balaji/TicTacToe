module TicTacToe
  module Game
    module Status
      IN_PROGRESS = :in_progress
      WON = :won
      DRAWN = :draw
    end

    def self.mark(row, column, game_state)
      grid = game_state['grid']
      game_status = game_state['game_status']

      if row < 0 || column < 0 || row > 2 || column > 2 ||
          grid[row][column] != '-' || game_status != Status::IN_PROGRESS.to_s
        raise 'Invalid mark'
      end

      if game_state['next_turn'] == 'a'
        grid[row][column] = 'X'
        next_turn = 'b'
      else
        grid[row][column] = 'O'
        next_turn = 'a'
      end

      {grid: grid, next_turn: next_turn, game_status: won(grid)}
    end

    def self.won(grid)

      # same diagonals
      diagonal = (0..2).collect { |i| grid[i][i] }
      return Status::WON if is_a_win?(diagonal)

      (0..2).each do |row|
        # same rows
        return Status::WON if is_a_win?(grid[row])

        # same columns
        column = (0..2).collect { |i| grid[i][row] }
        return Status::WON if is_a_win?(column)
      end

      return Status::DRAWN if is_a_draw?(grid)

      Status::IN_PROGRESS
    end

    private
    def self.is_a_win?(array)
      array.all? { |x| x == array[0] && x != '-' }
    end

    def self.is_a_draw?(grid)
      uniq_blocks = grid.flatten.uniq
      uniq_blocks.length == 2 && !uniq_blocks.include?('-')
    end
  end
end