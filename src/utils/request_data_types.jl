# API requests data structures

# report request
struct Request
    report_requests::Vector{ReportRequest}
    use_resource_quotas::Bool
end

struct ReportRequest
    viewid::AbstractString
    dateranges::DateRange
    sampling_level::SamplingLevel
    dimensions::Vector{Dimension}
    dimension_filters::DimensionFilter
    metrics::Vector{Metric}
    metric_filters::MetricFilter
    filter::AbstractString
    order_by::OrderBy
    segments::Segment
    pivots::Pivot
    cohort_group::CohortGroup
    page_token::AbstractString
    page_size::Integer
    include_null_rows::Bool
    hide_totals::Bool
    hide_value_ranges::Bool
end

@enum SamplingLevel begin
    SAMPLING_UNSPECIFIED
    DEFAULT
    SMALL
    LARGE
end

# generics

@enum GeneralOperator begin
    OPERATOR_UNSPECIFIED
    REGEXP
    BEGINS_WITH
    ENDS_WITH
    PARTIAL
    EXACT
    NUMERIC_EQUAL
    NUMERIC_GREATER_THAN
    NUMERIC_LESS_THAN
    IN_LIST
end

# general dimension struct
struct Dimension
    name::AbstractString
    histogram_buckets::Vector{Int64}
end

@enum DimensionOperator begin
    OPERATOR_UNSPECIFIED
    OR
    AND
end


struct DimensionFilter
    dimension_name::AbstractString
    not::Bool
    operator::GeneralOperator
    expressions::Vector{AbstractString}
    case_sensitive::Bool
end


struct DimensionFilter
    operator::DimensionOperator
    filters::Vector{DimensionFilter}
end

# Metrics related

@enum MetricType begin
    METRIC_TYPE_UNSPECIFIED
    INTEGER
    FLOAT
    CURRENCY
    PERCENT
    TIME
end

@enum MetricOperator begin
    OPERATOR_UNSPECIFIED
    EQUAL
    LESS_THAN
    GREATER_THAN
    IS_MISSING
end

struct Metric
    expression::AbstractString
    alias::AbstractString
    formatting_type::MetricType
end

struct MetricFilter
    metric_name::AbstractString
    not::Bool
    operator::MetricOperator
end

@enum OrderType begin
    ORDER_TYPE_UNSPECIFIED
    VALUE
    DELTA
    SMART
    HISTOGRAM_BUCKET
    DIMENSION_AS_INTEGER
end

struct OrderBy
    field_name::AbstractString
    order_type::OrderType
    sort_order::SortOrder
end

@enum SortOrder begin
end

struct Segment end

struct DynamicSegment end

struct SegmentDefinition end

struct SegmentFilter end

struct SimpleSegment end

struct SequenceSegment end

struct OrFiltersForSegment end

struct SegmentFilterClause end

struct SegmentDimensionFilter end

struct SegmentMetricFilterClause end

struct SegmentSequenceStep end

@enum Scope begin
end

@enum MatchType begin
end

struct Pivot end


# cohorts
struct CohortGroup end

struct Cohort end

@enum CohortType begin
end
