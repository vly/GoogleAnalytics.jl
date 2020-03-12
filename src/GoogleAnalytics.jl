module GoogleAnalytics

using JSON3
using HTTP
using JSON
using Base64
import Base: show
import MbedTLS
using Dates
using Sockets
using Lazy

include("utils/authentication.jl")

export authenticate, JWTAuth

end # module
