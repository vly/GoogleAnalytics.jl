# handles google authentication

# temp loads while testing
using JSON3
using HTTP
using JSON
using Base64
import Base: show
import MbedTLS
using Dates
using Sockets
using Lazy

const api_scope = "https://www.googleapis.com/auth/analytics.readonly"
const api_endpoint = "https://analyticsreporting.googleapis.com/v4/reports:batchGet"

struct Servicekey
    type::String
    project_id::String
    private_key_id::String
    private_key::String
    client_email::String
    client_id::String
    auth_uri::String
    token_uri::String
    auth_provider_x509_cert_url::String
    client_x509_cert_url::String
end

StructTypes.StructType(::Type{Servicekey}) = StructTypes.Struct()

mutable struct Credentials
    access_token::String
    refresh_token::String
end

# functions prototypes
function load_keyfile(file_location::AbstractString) end
function Base.show(io::IO, key::Servicekey) end
function refresh_access_token(creds::Credentials) end

# service key functions
function load_keyfile(file_location::AbstractString)
    open(file_location, "r") do f
        JSON3.read(f, Servicekey)
    end
end

# extend base show function for Servicekey objects
function Base.show(io::IO, key::Servicekey)
    print(io, "Service key data:\n")
    print(io, "type:\t", key.type, "\n")
    print(io, "project_id:\t", key.project_id, "\n")
    print(io, "private_key_id:\t", key.private_key_id, "\n")
    print(io, "private_key:\t", key.private_key, "\n")
    print(io, "client_email:\t", key.client_email, "\n")
    print(io, "client_id:\t", key.client_id, "\n")
    print(io, "auth_uri:\t", key.auth_uri, "\n")
    print(io, "token_uri:\t", key.token_uri, "\n")
    print(io, "auth_provider_x509_cert_url:\t", key.auth_provider_x509_cert_url, "\n")
    print(io, "client_x509_cert_url:\t", key.client_x509_cert_url, "\n")
end

# ------------------ Shamelessly lifted from GitHub.jl (thanks for saving my sanity!)
const ENTROPY = Ref{MbedTLS.Entropy}()
const RNG     = Ref{MbedTLS.CtrDrbg}()


ENTROPY[] = MbedTLS.Entropy()
RNG[]     = MbedTLS.CtrDrbg()
MbedTLS.seed!(RNG[], ENTROPY[])


#######################
# Authorization Types #
#######################

abstract type Authorization end

# TODO: SecureString on 0.7
struct OAuth2 <: Authorization
    token::String
end

struct UsernamePassAuth <: Authorization
    username::String
    password::String
end

struct AnonymousAuth <: Authorization end

struct JWTAuth <: Authorization
    JWT::String
end

####################
# JWT Construction #
####################

function base64_to_base64url(string)
    replace(replace(replace(string, "=" => ""), '+' => '-'), '/' => '_')
end

function JWTAuth(app_id::Int, key::MbedTLS.PKContext; servicekey::Servicekey, iat = now(Dates.UTC), exp_mins = 1)
    algo = base64_to_base64url(base64encode(JSON.json(Dict(
        "alg" => "RS256",
        "typ" => "JWT"
    ))))
    data = base64_to_base64url(base64encode(JSON.json(Dict(
        "iss"      => servicekey.client_email,
        "scope"    => "https://www.googleapis.com/auth/analytics.readonly",
        "aud"      => servicekey.token_uri,
        "exp" => trunc(Int64, Dates.datetime2unix(iat+Dates.Minute(exp_mins))),
        "iat" => trunc(Int64, Dates.datetime2unix(iat))

    ))))
    signature = base64_to_base64url(base64encode(MbedTLS.sign(key, MbedTLS.MD_SHA256,
        MbedTLS.digest(MbedTLS.MD_SHA256, string(algo,'.',data)), RNG[])))
    JWTAuth(string(algo,'.',data,'.',signature))
end

function JWTAuth(app_id::Int, privkey::String; kwargs...)
    JWTAuth(app_id, MbedTLS.parse_keyfile(privkey); kwargs...)
end


#########################
# Header Authentication #
#########################

authenticate_headers!(headers, auth::AnonymousAuth) = headers

function authenticate_headers!(headers, auth::OAuth2)
    headers["Authorization"] = "token $(auth.token)"
    return headers
end

function authenticate_headers!(headers, auth::JWTAuth)
    headers["Authorization"] = "Bearer $(auth.JWT)"
    return headers
end

function authenticate_headers!(headers, auth::UsernamePassAuth)
    headers["Authorization"] = "Basic $(base64encode(string(auth.username, ':', auth.password)))"
    return headers
end

###################
# Pretty Printing #
###################

function Base.show(io::IO, a::OAuth2)
    token_str = a.token[1:6] * repeat("*", length(a.token) - 6)
    print(io, "GitHub.OAuth2($token_str)")
end


token_endpoint = "https://oauth2.googleapis.com/token"
grant = HTTP.escapeuri("urn:ietf:params:oauth:grant-type:jwt-bearer")
auth = JWTAuth(0, "examples/test.pem"; servicekey = servicekey).JWT
# payload = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=$auth"
payload = Dict(
    "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "assertion" => auth
)
raw_response = HTTP.request("POST", token_endpoint, ["Content-Type" => "application/json"], JSON.json(payload))
response = String(raw_response.body)
access_token_blob = JSON.parse(response)

# test request
access_token = access_token_blob["access_token"]
token_type = access_token_blob["token_type"]
payload = Dict(
        "reportRequests" => [Dict(
            "viewId"        => "43047246",
            "dateRanges"    => [Dict(
                                    "startDate" => "7daysAgo",
                                    "endDate" => "today"),],
          "metrics"         => [Dict("expression" => "ga:sessions"),],
          "dimensions" => [Dict("name" => "ga:country"),]
        ),]
      )

batchGet_endpoint = "https://analyticsreporting.googleapis.com/v4/reports:batchGet"
raw_response = HTTP.request("POST",
    batchGet_endpoint,
    ["Authorization" => "$token_type $access_token"],
    JSON.json(payload)
)
response = String(raw_response.body)
JSON.parse(response)
