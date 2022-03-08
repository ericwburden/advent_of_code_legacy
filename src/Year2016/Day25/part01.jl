#=------------------------------------------------------------------------------
| cpy a d	|
| cpy 4 c	|
| cpy 633 b	|
| inc d		|
| dec b		|
| jnz b -2	|
| dec c		|
| jnz c -5	|   d = a + (4 * 633)
|           |   loop {
| cpy d a	|     a = d
| jnz 0 0	|     do {
| cpy a b	|       c = 2 - (a % 2)
| cpy 0 a	|       a = a / 2
| cpy 2 c	|       
| jnz b 2	|
| jnz 1 6	|
| dec b		|
| dec c		|
| jnz c -4	|
| inc a		|      
| jnz 1 -7	|
| cpy 2 b	|       b = c + 2
| jnz c 2	|
| jnz 1 4	|
| dec b		|
| dec c		|
| jnz 1 -4	|
| jnz 0 0	|
| out b		|       output b
| jnz a -19	|     } while a != 0
| jnz 1 -21	|   }
------------------------------------------------------------------------------=#

function part1()
    for n in 1:typemax(Int)
        a = d = n + (4 * 633)
        expected = 0
        matches  = 0

        while true
            a, b = divrem(a, 2)
            if b == expected
                expected = expected == 0 ? 1 : 0
                matches += 1
                matches > 10 && return n
            else
                break
            end
            if (a == 0) a = d end
        end
    end
end