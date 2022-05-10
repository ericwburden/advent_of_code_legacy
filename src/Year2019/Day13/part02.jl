"""
    part2(input) -> Int

Initialize a computer with the provided IntCode program and set the first
memory entry to `2`. Draw the screen, then repeatedly take input and run
until no block tiles are remaining. Return the final score of the game.
"""
function part2(input)
    # Initialize the computer
    computer = Computer(input)
    computer[0] = 2
    computer, tiles = draw_screen!(computer)
    add_input!(computer, 0) # Start by not moving the joystick

    # The current score and x-coordinates of the paddle and ball
    score, paddle, ball = (0, 0, 0)

    # While there are blocks remaining...
    while count_blocks(tiles) > 0
        # Run the computer until it pauses for intake
        computer = run!(computer)
        
        # Take output three values at a time, updating the
        # tiles as appropriate, and keeping track of the horizontal
        # positions of the paddle and ball.
        while !isempty(computer.output)
            x    = get_output!(computer)
            y    = get_output!(computer)
            tile = get_output!(computer)

            x    == -1 && (score = tile)
            tile ==  3 && (paddle = x)
            tile ==  4 && (ball = x)
            tiles[(x, y)] = tile
        end

        # Use input to direct the joystick to move the paddle in the
        # x-direction of the ball, keeping them in line if possible.
        joystick = sign(ball - paddle)
        add_input!(computer, joystick)
    end

    # Return the final observed score
    return score
end
