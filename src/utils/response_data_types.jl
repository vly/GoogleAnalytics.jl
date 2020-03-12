# API response data structures

struct Report
    column_header::ColumnHeader
    data::ReportData
    next_page_token::AbstractString
end
struct ColumnHeader
    dimensions::Vector{AbstractString}
    metric_header::MetricHeader
end

struct ReportData
    rows::Vector{ReportRow}
    totals::Vector{DateRangeValues}
    row_count::Integer
    minimums::Vector{DateRangeValues}
    maximums::Vector{DateRangeValues}
    samples_read_counts::Vector{Float64}
    sampling_space_sizes::Vector{Float64}
    is_data_golden::Bool
    data_last_refreshed::Dates.DateTime
end

struct MetricHeader
    metric_header_entries::Vector{MetricHeaderEntry}
    pivot_headers::Vector{PivotHeader}
end

struct MetricHeaderEntry
    name::AbstractString
    type::MetricType
end

struct PivotHeader
    pivot_header_entries::Vector{PivotHeaderEntry}
    total_pivot_groups_count::Integer
end

struct PivotHeaderEntry
    dimension_names::Vector{AbstractString}
    dimension_values::Vector{AbstractString}
    metric::MetricHeaderEntry
end

struct ReportRow
    dimensions::Vector{AbstractString}
    metrics::Vector{DateRangeValues}
end

struct DateRangeValues
    values::Vector{AbstractString}
    pivot_value_regions::Vector{PivotValueRegion}
end

struct PivotValueRegion
    values::Vector{AbstractString}
end

struct ResourceQuotasRemaining
    daily_quote_tokens_remaining::Integer
    hourly_quota_tokens_remaining::Integer
end
