using GoogleAnalytics
using Test

printstyled("Running tests:\n", color=:blue)

include("authentication.jl")
include("data_formatting.jl")
include("api_comms.jl")
