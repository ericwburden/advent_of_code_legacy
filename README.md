# Eric's Legacy Advent of Code Solutions (2015 - 2019)

## The Blog

I first learned about Advent of Code in 2020, and I absolutely fell in love with the
event. For me, AoC has proven to be a really excellent tool for learning/practicing
a new programming language. To date, I have used AoC to learn both Rust and Julia. I'll
probably continue this trend in subsequent years as well. I've blogged my approaches
to the [2020](https://www.ericburden.work/categories/advent-of-code-2020/) puzzles in 
R and the [2021](https://www.ericburden.work/categories/advent-of-code-2021/) puzzles
in Julia. During early 2021, I re-solved all the puzzles in Rust. Each blog post
includes not only the code but some commentary on the thinking behind the approach and
my thoughts about the puzzles in general.

## This Repo

After solving the 2021 puzzles in Julia, I decided that I'd like to collect all 350 (as
of 2021) stars from past years. Thus began an ~5 month journey of working on old AoC
puzzles on and off in whatever free time I could scrounge up (from other, honestly more
important things like spending time with family). This repo contains all the Julia code
I wrote to earn those stars! I can't imagine that I'll try to blog about these, since 
(a) these are old puzzles and not likely to be as interesting to others and (b) that's
a lot of work!

![pics because it happened](https://user-images.githubusercontent.com/22438085/170024255-6d74f4f2-34d7-4728-9aaf-e54b2abece1b.png)

## Project Structure

For speed and ease of use, I used a variant of my 2021 Julia project structure for 
years 2015-2019, with an extra layer of nesting for each year. Unlike 2021, I didn't 
include benchmarks or tests, because I had 5 years' worth of puzzles to complete!

### Julia Project

The project structure looks like this:

```
AdventOfCode
├─inputs
│ └─YYYY
│   └─DD
│     ├─input.txt
│     └─test.txt
├─src
│ ├─YearXXXX
│ │ └─DayXX
│ │   ├─DayXX.jl
│ │   ├─ingest.jl
│ │   ├─part01.jl
│ │   └─part02.jl
│ ├─AdventOfCode.jl
│ ├─run.jl
│ └─template.jl
├─Manifest.toml
└─Project.toml
```

With the `AdventOfCode` package activated (see below):

- Get the results for a particular day with `julia src/run.jl -y 2015 -d 1`
- Template a new day with `julia src/template.jl -y 2022 -d 1`

Templating a new day entails creating a 'Day' folder in the appropriate 'Year' (you
should create your 'Year' folder manually, feel free to copy the contents of a previous
'Year') with template scripts for `ingest.jl`, `part01.jl`, and `part02.jl`. You can
copy your session cookie into a `src/.cookie` file, and the template script will
also download your input into `inputs` for your. Otherwise, it'll tell you to do it
yourself.


**Note on Julia project activation**

To conveniently use the commands listed above, add the following to your `/.julia/config/startup.jl`:

```julia
using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end
```



