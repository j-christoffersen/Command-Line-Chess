require 'chess.rb'

$test = true

RSpec.configure do |c|
  c.before { allow($stdout).to receive(:puts) }
end

describe 'Board' do
    before(:each) do
        @board = Board.new
        $stdout = StringIO.new
    end
    
    after(:each) do
        $stdout = STDOUT
    end
    
    describe '#at' do
        it 'returns the value at a certain space' do
            expect(@board.at([4, 0])).to eql(:bk)
        end
    end
    
    describe '#set' do
        it 'sets the value at given coordinates' do
            @board.set([4, 4], :bb)
            expect(@board.at([4, 4])).to eql(:bb)
        end
    end
    
    describe '#move' do
        before do
            @board.move([0,1], [3,4])
        end
        
        it 'moves a piece from one space to another' do
            expect(@board.at([3, 4])).to eql(:bp)
        end
        
        it 'leaves the other space empty' do
            expect(@board.at([0, 1])).to eql(0)
        end
        
        it 'changes the turn' do
            expect(@board.turn).to eql(P2)
        end
    end
    
    describe '#copy' do
        it 'returns a new board object identical to the current one' do
            @board.set([4, 4], :bb)
            copy = @board.copy
            expect(copy.at([4, 4])).to eql(:bb)
        end
    end
end

describe 'Chess' do
    before(:each) do
        $stdout = StringIO.new
        @game = Chess.new
    end
    
    after(:each) do
        $stdout = STDOUT
    end
    
    describe '.owner' do
        it 'returns the owner of a piece' do
            expect(Chess.owner[:wk]).to eql(P1)
        end
    end
    
    describe '.diff' do
        context 'given two vectors' do
            it 'returns the absolute value of the difference between said vectors' do
                expect(Chess.diff([1, 2 ,3], [3, 2, 0])).to eql([2, 0, 3])
            end
        end
    end
    
    describe "#check?" do
        
        context "if in check" do
            it "returns true" do
                @game.move([2, 6], [2, 5])
                @game.move([3, 1], [3, 3])
                @game.move([3, 7], [0, 4])
                expect(@game.check?).to eql(true)
            end
        end
        
        context "if not in check" do
            it "returns false" do
                expect(@game.check?).to eql(false)
            end
        end
    end
    
    describe '#is_valid_move' do
        
        context "piece is pawn" do
            it "can moves forward one space" do
                expect(@game.is_valid_move([0, 6], [0, 5])).to eql(true)
            end
            
            it "can capture diagonally" do
                @game.board.set([1, 5], :bp)
                expect(@game.is_valid_move([0, 6], [1, 5])).to eql(true)
            end
            
            it "can't move forward two spaces" do
                @game.board.set([3, 5], :wp)
                expect(@game.is_valid_move([3, 5], [3, 3])).to eql(false)
            end
            
            it "can move forward 2 spaces if in original spot" do
                expect(@game.is_valid_move([0, 6], [0, 4])).to eql(true)
            end
            
            it "can't move diagonally into an empty space" do
                expect(@game.is_valid_move([0, 6], [1, 5])).to eql(false)
            end
            
            it "can't move forward to capture a piece" do
                @game.board.set([0, 5], :bp)
                expect(@game.is_valid_move([0, 6], [0, 5])).to eql(false)
            end
            
            it "can capture en passant" do
                @game.board.set([4,4], :wp)
                @game.move([4,4],[4,3])
                @game.move([5,1],[5,3])
                expect(@game.is_valid_move([4,3],[5,2])).to eql(true)
                @game.board.move([4,3],[5,2])
                expect(@game.board.at([5,3])).to eql(0)
            end
        end
        
        context "piece is rook" do
            it "can move vertically" do
                @game.board.set([0, 6], 0)
                expect(@game.is_valid_move([0, 7], [0, 4])).to eql(true)
            end
            
            it "can move horizontally" do
                @game.board.set([0, 4], :wr)
                expect(@game.is_valid_move([0, 4], [4, 4])).to eql(true)
            end
            
            it "can't move if a piece is blocking" do
                expect(@game.is_valid_move([0, 7], [0, 4])).to eql(false)
            end
            
            it "can't move diagonally" do
                @game.board.set([1, 6], 0)
                expect(@game.is_valid_move([0, 7], [2, 5])).to eql(false)
            end
        end
        
        context "piece is knight" do
            it "can move in a knightly fashion" do
                expect(@game.is_valid_move([1,7], [2,5])).to eql(true)
            end
            
            it "can't move some other way" do
                expect(@game.is_valid_move([1,7], [3,5])).to eql(false)
            end
        end
        
        context "piece is bishop" do
            it "can move diagonally" do
                @game.board.set([3, 6], 0)
                expect(@game.is_valid_move([2, 7], [4, 5])).to eql(true)
            end
            
            it "can't move if a piece is blocking" do
                expect(@game.is_valid_move([2, 7], [4, 5])).to eql(false)
            end
            
            it "can't move vertically" do
                @game.board.set([2, 6], 0)
                expect(@game.is_valid_move([2, 7], [2, 4])).to eql(false)
            end
        end
        
        context "piece is queen" do
            it "can move vertically" do
                @game.board.set([3, 6], 0)
                expect(@game.is_valid_move([3, 7], [3, 4])).to eql(true)
            end
            
            it "can move horizontally" do
                @game.board.set([0, 4], :wr)
                expect(@game.is_valid_move([0, 4], [4, 4])).to eql(true)
            end
            
            it "can't move if a piece is blocking" do
                expect(@game.is_valid_move([3, 7], [3, 4])).to eql(false)
            end
            
            it "can move diagonally" do
                @game.board.set([4, 6], 0)
                expect(@game.is_valid_move([3, 7], [5, 5])).to eql(true)
            end
            
            it "can't move to another spot" do
                @game.board.set([4, 6], 0)
                expect(@game.is_valid_move([3, 7], [5, 6])).to eql(false)
            end
        end
        
        context "piece is king" do
            it "can move one square forward" do
                @game.board.set([4,6], 0)
                expect(@game.is_valid_move([4, 7],[4,6])).to eql(true)
            end
            
            it "can move one square diagonally" do
                @game.board.set([5,6], 0)
                expect(@game.is_valid_move([4, 7],[5,6])).to eql(true)
            end
            
            it "can't move two squares" do
                @game.board.set([4,6], 0)
                expect(@game.is_valid_move([4, 7],[4,5])).to eql(false)
            end
            
            it "can castle kingside" do
                @game.board.set([5,7], 0)
                @game.board.set([6,7], 0)
                expect(@game.is_valid_move([4, 7],[7, 7])).to eql(true)
            end
            
            it "can castle queenside" do
                @game.board.set([3,7], 0)
                @game.board.set([2,7], 0)
                @game.board.set([1,7], 0)
                expect(@game.is_valid_move([4, 7],[0, 7])).to eql(true)
            end
            
            it "can't castle through check" do
                @game.board.set([2,6], 0)
                @game.board.set([2,5], :br)
                @game.board.set([3,7], 0)
                @game.board.set([2,7], 0)
                @game.board.set([1,7], 0)
                expect(@game.is_valid_move([4, 7],[0, 7])).to eql(false)
            end
        end
        
        context "puts self in check" do
            it "returns false" do
                @game.move([4,6], [4,5])
                @game.move([7,1], [7,2])
                @game.move([5,7],[1,3])
                expect(@game.is_valid_move([3, 1],[3, 2])).to eql(false)
            end
        end
        
        context "spot is occupied" do
            it "returns false" do
                @game.board.set([0,5], :wp)
                expect(@game.is_valid_move([0, 6], [0, 5])).to eql(false)
            end
        end
        
        context "oppponents piece is selected" do
            it "returns false" do
                expect(@game.is_valid_move([1,1], [1,2])).to eql(false)
            end
        end
    end
    
    describe "#no_moves?" do
        context "if there are no legal moves" do
            it "returns true" do
                @game.move([5,6],[5,5])
                @game.move([4,1], [4,2])
                @game.move([6,6], [6,4])
                @game.move([3,0], [7,4])
                expect(@game.no_moves?).to eql(true)
            end
        end
        
        context "if there are moves" do
            it "returns false" do
                expect(@game.no_moves?).to eql(false)
            end
        end
    end
end
