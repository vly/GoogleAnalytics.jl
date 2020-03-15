module GoogleAnalytics

# for interaction with API endpoints
using JSON
using JSON3
using HTTP
import MbedTLS
using Base64
#using Sockets
# core
import Base: show
using Dates
using Lazy
# for data processing
using JuliaDB
# for data storage
using CSVFiles

export authenticate,
       JWTAuth

include("utils/request_data_types.jl")
include("utils/response_data_types.jl")
include("utils/authentication.jl")
include("utils/api_comms.jl")
include("utils/data_formatting.jl")

end # module
