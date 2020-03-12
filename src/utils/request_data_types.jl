# API requests data structures

# report request
struct Request
    reportRequests::Array{ReportRequest}
    useResourceQuotas::Bool
end

struct ReportRequest
    viewid::AbstractString
    dateranges::DateRange
    sampling_level::SamplingLevel
    dimensions::Array{Dimension}
    dimension_filters::DimensionFilter
    metrics::Array{Metric}
    metric_filters::MetricFilter
    filter::AbstractString
    orderBy::OrderBy
    segments::Segment
    pivots::Pivot
    cohortGroup::CohortGroup
    pageToken::AbstractString
    pageSize::Integer
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
    histogram_buckets::Array{Int64}
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
    expressions::Array{AbstractString}
    case_sensitive::Bool
end


struct DimensionFilter
    operator::DimensionOperator
    filters::Array{DimensionFilter}
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
    formattingType::MetricType
end

struct MetricFilter end

@enum OrderType begin

end

struct OrderBy end

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
