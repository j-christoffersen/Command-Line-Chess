$test = false

P1 = false
P2 = true

class Chess
    
    attr_reader :board
    
    @@owner = {
        br: P2,
        bh: P2, 
        bb: P2,
        bq: P2,
        bk: P2,
        bp: P2,
        wr: P1,
        wh: P1,
        wb: P1,
        wq: P1,
        wk: P1,
        wp: P1,
        0 => nil
    }
    
    @@symbol = {
        wr: "\u265C",
        wh: "\u265E", 
        wb: "\u265D",
        wq: "\u265B",
        wk: "\u265A",
        wp: "\u265F",
        br: "\u2656",
        bh: "\u2658",
        bb: "\u2657",
        bq: "\u2655",
        bk: "\u2654",
        bp: "\u2659",
        0 => "\u25B1"
    }
    
    def self.owner
        return @@owner
    end
    
    def self.diff(a, b)
        return a.map.with_index { |e, i| (e-b[i]).abs }
    end
    
    def initialize
        @board = Board.new
        @game_over = false
        puts "Welcome to chess!"
        display
        next_turn unless $test
    end
    
    def next_turn
        from = nil
        to = nil
        loop do
            move_coords = get_move
            from = move_coords[0]
            to = move_coords[1]
            break if is_valid_move(from, to)
        end
        move(from, to)
        display
        if check?
            if no_moves?
                puts "Player #{@board.turn ? '1' : '2'} wins!"
                @game_over = true
            else
                puts "Check!"
            end
        else
            if no_moves?
                puts "It's a draw!"
                @game_over = true
            end
        end
        next_turn unless @game_over
        
    end
    
    def display
        (0..7).each do |y|
            print (8-y).to_s + " "
            (0..7).each do |x|
                print @@symbol[@board.at([x,y])].encode('utf-8')
                print ' '
            end
            print "\n"
        end
        print "  A  B  C  D  E  F  G  H"
        print "\n"
    end
    
    def get_move
        from = []
        to = []
        loop do
            puts "What piece do you want to move?"
            from = gets.chomp.split('')
            if from.length == 2 && from[0].downcase.ord >= 97 && from[0].downcase.ord <= 104 && from[1].to_i >= 1 && from[1].to_i <= 8
                from[0] = from[0].downcase.ord - 97
                from[1] = 8 - from[1].to_i
                break
            end
            puts "Not a valid space"
        end
        
        loop do
            puts "Where do you want to move to?"
            to = gets.chomp.split('')
            if to.length == 2 && to[0].downcase.ord >= 97 && to[0].downcase.ord <= 104 && to[1].to_i >= 1 && to[1].to_i <= 8
                to[0] = to[0].downcase.ord - 97
                to[1] = 8 - to[1].to_i
                break
            end
            puts "Not a valid space"
        end
        
        return [from, to]
    end
    
    def move(from, to)
        @board.move(from, to)
    end
    
    def is_valid_move(from, to, show_messages = true)
        return false if is_valid_move_helper(from, to, show_messages) == false
        
        if @@owner[board.at(from)] == !board.turn
            puts "That's not your piece" if show_messages
            return false
        end
        
        new_board = @board.copy
        new_board.move(from, to)
        new_board.change_turn
        if check?(new_board)
            puts "You're in check!" if show_messages
            return false
        end
        return true
    end
    
    def is_valid_move_helper(from, to, show_messages=true, board=@board)
        unless(from[0] >= 0 && from[0] <= 7 && from[1] >= 0 && from[1] <= 7 && to[0] >= 0 && to[0] <= 7 && to[1] >= 0 && to[1] <= 7)
            puts "That space is not on the board" if show_messages
            return false
        end
        
        if board.at(from) == 0
            puts "You haven't selected a piece" if show_messages
            return false
        end
        
        #castling
        if (board.turn == P1 && from == [4,7] && to == [0,7] && board.at([0,7]) == :wr && board.at([4,7]) == :wk && board.at([1,7]) == 0 && board.at([2,7]) == 0 && board.at([3,7]) == 0)
            [[1,7],[2,7],[3,7]].each do |move_through|
                new_board = @board.copy
                new_board.move(from, move_through)
                new_board.change_turn
                if check?(new_board)
                    puts "you can't castle through check!" if show_messages
                    return false
                end
            end
            return true
        elsif (board.turn == P1 && from == [4,7] && to == [7,7] && board.at([7,7]) == :wr && board.at([4,7]) == :wk && board.at([6,7]) == 0 && board.at([5,7]) == 0)
            [[6,7],[5,7]].each do |move_through|
                new_board = @board.copy
                new_board.move(from, move_through)
                new_board.change_turn
                if check?(new_board)
                    puts "you can't castle through check!" if show_messages
                    return false
                end
            end
            return true
        elsif (board.turn == P2 && from == [4,0] && to == [0,0] && board.at([0,0]) == :br && board.at([4,7]) == :bk && board.at([1,0]) == 0 && board.at([2,0]) == 0 && board.at([3,0]) == 0)
            [[1,0],[2,0],[3,0]].each do |move_through|
                new_board = @board.copy
                new_board.move(from, move_through)
                new_board.change_turn
                if check?(new_board)
                    puts "you can't castle through check!" if show_messages
                    return false
                end
            end
            return true
        elsif (board.turn == P2 && from == [4,0] && to == [7,0] && board.at([7,0]) == :br && board.at([4,7]) == :bk && board.at([6,0]) == 0 && board.at([5,0]) == 0)
            [[5,0],[6,0]].each do |move_through|
                new_board = @board.copy
                new_board.move(from, move_through)
                new_board.change_turn
                if check?(new_board)
                    puts "you can't castle through check!" if show_messages
                    return false
                end
            end
            return true
        end
        
        unless board.at(to) == 0 || @@owner[board.at(to)] == !board.turn
               
            puts "That spot is occupied" if show_messages
            return false
        end
        
        piece = board.at(from)
        
        case piece
        when :wh, :bh
            d = self.class.diff(to, from)
            unless d == [2, 1] || d == [1, 2]
                puts "Knights can only move two-forward, one sideways" if show_messages
                return false
            end

        when :wk, :bk
            d = self.class.diff(to, from)
            unless d == [1, 1] || d == [1, 0] || d == [0, 1]
                  
                puts "Kings can only move one square in any direction" if show_messages
                return false
            end
            
        when :br, :wr
            if to[0] == from[0]
                i = from[1]
                dir = to[1] > from[1] ? 1 : -1
                i += dir
                until i == to[1] do
                    if board.at([to[0], i]) != 0
                        puts "there's a piece in the way!" if show_messages
                        return false
                    end
                    i += dir
                end
            elsif to[1] == from[1]
                i = from[0]
                dir = to[0] > from[0] ? 1 : -1
                i += dir
                until i == to[0] do
                    if board.at([i, to[1]]) != 0
                        puts "there's a piece in the way!" if show_messages
                        return false
                    end
                    i += dir
                end
            else
                puts "rooks can only move vertically or horizontally" if show_messages
                return false
            end
            
        when :wb, :bb
            d = self.class.diff(to, from)
            unless d[0] == d[1]
                puts "bishops can only move diagonally" if show_messages
                return false
            end
            xdir = to[0] > from[0] ? 1 : -1
            ydir = to[1] > from[1] ? 1 : -1
            x = from[0] + xdir
            y = from[1] + ydir
            until x == to[0] do
                if board.at([x, y]) != 0
                    puts "there's a piece in the way!" if show_messages
                    return false
                end
                x += xdir
                y += ydir
            end
            
        when :wq, :bq
            d = self.class.diff(to, from)
            unless d[0] == d[1] || d[0] = 0 || d[1] = 0
                puts "queens can only move horizontally, vertically, or diagonally" if show_messages
                return false
            end
            xdir = to[0] == from[0] ? 0 : (to[0] > from[0] ? 1 : -1)
            ydir = to[1] == from[1] ? 0 : (to[1] > from[1] ? 1 : -1)
            x = from[0] + xdir
            y = from[1] + ydir
            until x == to[0] && y == to[1] do
                if board.at([x, y]) != 0
                    puts "there's a piece in the way!" if show_messages
                    return false
                end
                x += xdir
                y += ydir
            end
            
        when :wp
            unless ( to[0] == from[0] && to[1] == from[1] - 1 && board.at(to) == 0 )  ||
                   ( (to[0] == from[0] + 1 || to[0] == from[0] - 1) && to[1] == from[1] - 1 && (board.passant_coords == to || @@owner[board.at(to)] == P2) ) ||
                   ( to[0] == from[0] && to[1] == from[1] - 2 && from[1] == 6 && board.at(to) == 0 )
                puts "pawns can only move forward, or diagonally when capturing" if show_messages
                return false
            end
        
        when :bp
            unless ( to[0] == from[0] && to[1] == from[1] + 1 && board.at(to) == 0 )  ||
                   ( (to[0] == from[0] + 1 || to[0] == from[0] - 1) && to[1] == from[1] + 1 && (board.passant_coords == to || @@owner[board.at(to)] == P1)) ||
                   ( to[0] == from[0] && to[1] == from[1] + 2 && from[1] == 1 && board.at(to) == 0 )
                puts "pawns can only move forward, or diagonally when capturing" if show_messages
                return false
            end
            
        #TODO: en passant
            
        end
        
        return true
    end
    
    #Am I in check?
    def check? (brd=@board)
        
        brd.change_turn

        brd.pieces[brd.turn].each do |piece_coords|
            if is_valid_move_helper(piece_coords, brd.king[!brd.turn], false, brd)

                brd.change_turn
                return true
            end
        end
        

        brd.change_turn
        return false
    end
    
    def potential_moves from
        piece = @board.at(from)
        out = []
        case piece
        
        when :wp
            return [[from[0], from[1]+1], [from[0], from[1]+2], [from[0]-1, from[1]+1],  [from[0]+1, from[1]+1]]
            
        when :bp
            return [[from[0], from[1]-1], [from[0], from[1]-2], [from[0]-1, from[1]-1],  [from[0]+1, from[1]-1]]
            
        when :wh, :bh
            return [[from[0]+1, from[1]+2], [from[0]-1, from[1]+2], [from[0]+1, from[1]-2], [from[0]-1, from[1]-2],
                    [from[0]+2, from[1]+1], [from[0]+2, from[1]-1], [from[0]-2, from[1]+1], [from[0]-2, from[1]-1]]
            
        when :wk, :bk
            return [[from[0]+1, from[1]+1], [from[0], from[1]+1], [from[0]-1, from[1]+1], [from[0]-1, from[1]],
                    [from[0]-1, from[1]-1], [from[0], from[1]-1], [from[0]+1, from[1]-1], [from[0]+1, from[1]]]
                    
        when :wr, :br
            i = 1
            while from[0] + i <= 7 do
                out.push [from[0]+i, from[1]]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 do
                out.push [from[0]-i, from[1]]
                i += 1
            end
            
            i = 1
            while from[1] + i <= 7 do
                out.push [from[0], from[1]+i]
                i += 1
            end
            
            i = 1
            while from[1] - i >= 0 do
                out.push [from[0], from[1]-i]
                i += 1
            end
            
        when :bb, :wb
            i = 1
            while from[0] + i <= 7 && from[1] + i <= 7 do
                out.push [from[0]+i, from[1]+i]
                i += 1
            end
            
            i = 1
            while from[0] + i <= 7 && from[1] - i >= 0 do
                out.push [from[0]+i, from[1]-i]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 && from[1] + i <= 7 do
                out.push [from[0]-i, from[1]+i]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 && from[1] - i >= 0 do
                out.push [from[0]-i, from[1]-i]
                i += 1
            end
            
        when :wq, :bq
            i = 1
            while from[0] + i <= 7 do
                out.push [from[0]+i, from[1]]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 do
                out.push [from[0]-i, from[1]]
                i += 1
            end
            
            i = 1
            while from[1] + i <= 7 do
                out.push [from[0], from[1]+i]
                i += 1
            end
            
            i = 1
            while from[1] - i >= 0 do
                out.push [from[0], from[1]-i]
                i += 1
            end
            
            i = 1
            while from[0] + i <= 7 && from[1] + i <= 7 do
                out.push [from[0]+i, from[1]+i]
                i += 1
            end
            
            i = 1
            while from[0] + i <= 7 && from[1] - i >= 0 do
                out.push [from[0]+i, from[1]-i]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 && from[1] + i <= 7 do
                out.push [from[0]-i, from[1]+i]
                i += 1
            end
            
            i = 1
            while from[0] - i >= 0 && from[1] - i >= 0 do
                out.push [from[0]-i, from[1]-i]
                i += 1
            end
        end
        return out
    end
    
    def no_moves?

        @board.pieces[@board.turn].each do |from|
            potential_moves(from).each do |to|
                if is_valid_move(from, to, false)
                    return false
                end
            end
        end
        
        return true
    end

end

class Board
    attr_reader :spaces, :pieces, :turn, :king, :passant_coords
    
    def initialize copy_board=nil
        if copy_board == nil
            @spaces = [[:br, :bh, :bb, :bq, :bk, :bb, :bh, :br],
                      [:bp, :bp, :bp, :bp, :bp, :bp, :bp, :bp],
                      [0, 0, 0, 0, 0, 0, 0, 0,],
                      [0, 0, 0, 0, 0, 0, 0, 0,],
                      [0, 0, 0, 0, 0, 0, 0, 0,],
                      [0, 0, 0, 0, 0, 0, 0, 0,],
                      [:wp, :wp, :wp, :wp, :wp, :wp, :wp, :wp],
                      [:wr, :wh, :wb, :wq, :wk, :wb, :wh, :wr]]
                      
            @pieces = {
                P1 => [[0,6], [0,7], [1,6], [1,7], [2,6], [2,7], [3,6], [3,7],
                       [4,6], [4,7], [5,6], [5,7], [6,6], [6,7], [7,6], [7,7]],
                          
                P2 => [[0,0], [0,1], [1,0], [1,1], [2,0], [2,1], [3,0], [3,1],
                       [4,0], [4,1], [5,0], [5,1], [6,0], [6,1], [7,0], [7,1]]
            }
            
            @turn = P1
            
            @king = { P1 => [4,7], P2 => [4,0] }
            
            @passant_coords = nil
            
        else
            @spaces = copy_board.spaces.map do |row|
                row.map { |e| e }
            end
            @turn = copy_board.turn
            
            @king = {}
            copy_board.king.each_pair { |key, value| @king[key] = value.clone }
            
            @pieces = {}
            copy_board.pieces.each_pair do |key, value|
                @pieces[key] = value.map { |e| e.clone }
            end
            @passant_coords = copy_board.passant_coords
        end
    end
    
    def at(coords)
        return @spaces[coords[1]][coords[0]]
    end
    
    def set(coords, value)

        @pieces[P1].delete coords
        @pieces[P2].delete coords
        
        if value != 0
            
            @pieces[Chess.owner[value]].push coords
            
            if value == :wk
                @king[P1] = coords
            elsif value == :bk
                @king[P2] = coords
            end
            
            if coords[1] == 0 && value == :wp
                set(coords, :wq)
            elsif coords[1] == 7 && value == :bp
                set(coords, :bp)
            end

        end
        
        
        @spaces[coords[1]][coords[0]] = value
    end
    
    def move(from, to)
        
        
        if (at(from) == :wk && at(to) == :wr)
            set(to, :wk)
            set(from, :wr)
        elsif (at(from) == :bk && at(to) == :br)
            set(to, :bk)
            set(from, :br)
        else
            set(to, at(from))
            set(from, 0)
        end
        
        if to == passant_coords
            set([to[0], to[1] + (@turn ? -1 : 1)], 0)
        end
        
        if (at(to) == :wp || at(to) == :bp) && Chess.diff(to,from) == [0,2]
            @passant_coords = [to[0], to[1] + (@turn ? -1 : 1)]
        else
            @passant_coords = nil
        end
        
        change_turn
    end
    
    def change_turn
        @turn = !@turn
    end
    
    def copy
        new_board = Board.new self
        
        return new_board
    end
end

Chess.new if $test == false