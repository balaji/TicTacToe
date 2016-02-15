module TicTacToe
  # Author    :: Balaji Damodaran  (mailto:damodaran.balaji@gmail.com)
  # Copyright :: Copyright (c) 2016
  # License   :: Distributes under the same terms as Ruby
  #
  # This module holds the logic to mark a square in the Tic-Tac-Toe
  # game board. Also checks if the game is won or drawn or in progress.
  module Game
    module Status
      IN_PROGRESS = :in_progress
      WON = :won
      DRAWN = :draw
    end

    @move_data = {
      'a' => { grid: 'X', next_turn: 'b' },
      'b' => { grid: 'O', next_turn: 'a' }
    }

    # function that updates the grid status based on the user action
    # and returns the new state. It also indicates whether a game is
    # won, drawn or in progress.
    #
    # @param row - x co-ordinate of the square that needs to update
    # @param column - y co-ordinate of the square that needs to update
    # @param game_state - current state of the game.
    #
    # @raise Invalid mark, if x,y co-ords are invalid or if the game is over.
    #
    # @return - updated state of the game.
    def self.mark(row, column, game_state)
      grid = game_state['grid']
      game_status = game_state['game_status']['state']

      raise 'Invalid mark' if invalid?(column, game_status, grid, row)

      grid[row][column] = @move_data[game_state['next_turn']][:grid]
      next_turn = @move_data[game_state['next_turn']][:next_turn]

      { grid: grid, next_turn: next_turn, game_status: won(grid) }
    end

    private_class_method
    def self.won(grid)
      # same diagonals
      winning_status = diagonal_win(grid)
      return winning_status unless winning_status.nil?

      winning_status = straight_win(grid)
      return winning_status unless winning_status.nil?

      return { state: Status::DRAWN } if a_draw?(grid)

      { state: Status::IN_PROGRESS }
    end

    # function that checks if there is a win diagonally
    # - both left and right diagonals, in the grid.
    def self.diagonal_win(grid)
      left_diagonal = (0..2).collect { |i| grid[i][i] }
      return {
        state: Status::WON, winner_blocks: [[0, 0], [1, 1], [2, 2]]
      } if a_win?(left_diagonal)

      right_diagonal = (0..2).collect { |i| grid[i][2 - i] }
      return {
        state: Status::WON, winner_blocks: [[0, 2], [1, 1], [2, 0]]
      } if a_win?(right_diagonal)
    end

    # function that checks if there is a win horizontally or vertically
    # in the grid.
    def self.straight_win(grid)
      (0..2).each do |row|
        # same rows
        return {
          state: Status::WON, winner_blocks: [[row, 0], [row, 1], [row, 2]]
        } if a_win?(grid[row])

        # same columns
        column = (0..2).collect { |i| grid[i][row] }
        return {
          state: Status::WON, winner_blocks: [[0, row], [1, row], [2, row]]
        } if a_win?(column)
      end
      nil
    end

    def self.invalid?(column, game_status, grid, row)
      row < 0 || column < 0 || row > 2 || column > 2 ||
        grid[row][column] != '-' || game_status != Status::IN_PROGRESS.to_s
    end

    def self.a_win?(array)
      array.all? {  |x| x == array[0] && x != '-'  }
    end

    def self.a_draw?(grid)
      uniq_blocks = grid.flatten.uniq
      uniq_blocks.length == 2 && !uniq_blocks.include?('-')
    end
  end
end
