using Documenter, GoogleAnalytics

makedocs(;
    modules=[GoogleAnalytics],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/vly/GoogleAnalytics.jl/blob/{commit}{path}#L{line}",
    sitename="GoogleAnalytics.jl",
    authors="Val Lyashov, Envato",
    assets=String[],
)

deploydocs(;
    repo="github.com/vly/GoogleAnalytics.jl",
)
