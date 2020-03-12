module GoogleAnalytics

# for interaction with API endpoints
using JSON
using JSON3
using HTTP
import MbedTLS
using Base64
using Sockets

# core
import Base: show
using Dates
using Lazy

# for data processing
using JuliaDB

# for data storage
using CSVFiles


include("utils/authentication.jl")

export authenticate, JWTAuth

end # module
