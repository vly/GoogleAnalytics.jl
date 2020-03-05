# handles google authentication
import Base: show

const api_scope = "https://www.googleapis.com/auth/analytics.readonly"
const key_file = ''
const api_endpoint = HTTP.URI("https://analyticsreporting.googleapis.com/v4/reports:batchGet")
const oauth2_endpoint = HTTP.URI("https://oauth2.googleapis.com/token")

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
    @as keyfile JSON.parsefile(file_location) begin
        JSON2.write(keyfile)
        JSON2.read(keyfile, Servicekey)
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

# jwt stuff
function base64_clean(base64_string::String)
    @as value base64_string begin
        replace(value, "=" => "")
        replace(value, '+' => '-')
        replace(value, '/' => '_')
    end
end

function JWTAuth(servicekey::Servicekey; iat = now(Dates.UTC), exp_mins = 1)
    algo = @as algo Dict("alg"=>"RS256", "typ"=>"JWT") begin
        JSON.json(algo)
        base64encode(algo)
        base64_clean(algo)
    end

    data = @as key servicekey begin
        Dict("iss"      => key.client_email,
             "scope"    => api_scope,
             "aud"      => key.token_uri,
             "exp"      => trunc(Int64, Dates.datetime2unix(iat+Dates.Minute(1))),
             "iat"      => trunc(Int64, Dates.datetime2unix(iat)))
        JSON.json(key)
        base64encode(key)
        base64_clean(key)
    end

    key_string = read(open(joinpath(@__DIR__, "test.pem"), "r"))
    key = MbedTLS.PKContext()
    MbedTLS.parse_key!(key, key_string)

    signature = @as key key begin
        MbedTLS.sign(key,
            MbedTLS.MD_SHA256,
            MbedTLS.digest(MbedTLS.MD_SHA256, string(algo, '.', data)),
            RNG[])
        base64encode(key)
        base64_clean(key)
    end

    # signature =


    string(algo, '.', data, '.', signature)
end

function JWTAuth(app_id::Int, privkey::String; kwargs...)
    JWTAuth(app_id, MbedTLS.parse_keyfile(privkey); kwargs...)
end

function meh()
    HTTP.post(oauth2_endpoint, redirects = true)

    MbedTLS.parse_key!(MbedTLS.PKContext(),
        z.auth_provider_x509_cert_url,
        String)
