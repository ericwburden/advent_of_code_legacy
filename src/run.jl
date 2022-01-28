using ArgParse
import AdventOfCode


#=------------------------------------------------------------------------------ 
| ArgParse Settings 
------------------------------------------------------------------------------=#


settings = ArgParseSettings()

@add_arg_table! settings begin
    "--year", "-y"
    help = "Year to run"
    arg_type = Int
    default = 0
end

@add_arg_table! settings begin
    "--day", "-d"
    help = "Day to run"
    arg_type = Int
    default = 0
end

parsed_args = parse_args(settings)
year = parsed_args["year"]
day  = parsed_args["day"]


#=------------------------------------------------------------------------------
| Run the indicated Year/Day puzzle and display output
------------------------------------------------------------------------------=#

println("\nAdvent of Code Results:")

yearmodsym = Symbol("Year", year)
if isdefined(AdventOfCode, yearmodsym)
    yearmod    = getfield(AdventOfCode, yearmodsym)
    daymodname = Symbol("Day", lpad(day, 2, "0"))

    if isdefined(yearmod, daymodname)
        println("\n--- Year: $year ---")

        daymod = getfield(yearmod, daymodname)
        daymod.run()
    else
        println("\n Year $(year), Day $day has not been solved yet!")
    end

else
    println("\nNo puzzles solved for the year $(year)!")
end

