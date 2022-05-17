"""
    part2(input)

Given the input as a number, generate recipe scores until the sequence of
digits in the input have been generated. Return the number of recipe scores
generated up to, but not including, this sequence of digits.
"""
function part2(input)
    input_digits = reverse(digits(input))
    check_idx = length(input_digits) - 1
    score_tracker = ScoreTracker()
    still_searching = true

    while still_searching
        create!(score_tracker)

        while length(score_tracker.scoreboard) > check_idx
            check_idx += 1
            check_range = (check_idx-length(input_digits)+1):check_idx
            check_seq = @view score_tracker.scoreboard[check_range]
            if all(v -> v[1] == v[2], zip(check_seq, input_digits))
                still_searching = false
                break
            end
        end
    end # while still_searching

    return check_idx - length(input_digits)
end
