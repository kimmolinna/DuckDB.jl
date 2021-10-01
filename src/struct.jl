@enum DUCKDB_TYPE_::UInt32 begin 
	DUCKDB_TYPE_INVALID=1
	DUCKDB_TYPE_BOOLEAN
	DUCKDB_TYPE_TINYINT
	DUCKDB_TYPE_SMALLINT
	DUCKDB_TYPE_INTEGER
	DUCKDB_TYPE_BIGINT
	DUCKDB_TYPE_UTINYINT
	DUCKDB_TYPE_USMALLINT
	DUCKDB_TYPE_UINTEGER
	DUCKDB_TYPE_UBIGINT
	DUCKDB_TYPE_FLOAT
	DUCKDB_TYPE_DOUBLE
	DUCKDB_TYPE_TIMESTAMP
	DUCKDB_TYPE_DATE
	DUCKDB_TYPE_TIME
	DUCKDB_TYPE_INTERVAL
	DUCKDB_TYPE_HUGEINT
	DUCKDB_TYPE_VARCHAR
	DUCKDB_TYPE_BLOB
end

const DUCKDB_TYPE = DUCKDB_TYPE_
#=
typedef enum DUCKDB_TYPE {
	DUCKDB_TYPE_INVALID = 0,
	// bool
	DUCKDB_TYPE_BOOLEAN,
	// int8_t
	DUCKDB_TYPE_TINYINT,
	// int16_t
	DUCKDB_TYPE_SMALLINT,
	// int32_t
	DUCKDB_TYPE_INTEGER,
	// int64_t
	DUCKDB_TYPE_BIGINT,
	// uint8_t
	DUCKDB_TYPE_UTINYINT,
	// uint16_t
	DUCKDB_TYPE_USMALLINT,
	// uint32_t
	DUCKDB_TYPE_UINTEGER,
	// uint64_t
	DUCKDB_TYPE_UBIGINT,
	// float
	DUCKDB_TYPE_FLOAT,
	// double
	DUCKDB_TYPE_DOUBLE,
	// duckdb_timestamp
	DUCKDB_TYPE_TIMESTAMP,
	// duckdb_date
	DUCKDB_TYPE_DATE,
	// duckdb_time
	DUCKDB_TYPE_TIME,
	// duckdb_interval
	DUCKDB_TYPE_INTERVAL,
	// duckdb_hugeint
	DUCKDB_TYPE_HUGEINT,
	// const char*
	DUCKDB_TYPE_VARCHAR,
	// duckdb_blob
	DUCKDB_TYPE_BLOB
} duckdb_type;
=#
"""
Days are stored as days since 1970-01-01
Use the duckdb_from_date/duckdb_to_date function to extract individual information
"""
struct duckdb_date 
	days::Int32
end

struct duckdb_date_struct 
	year::Int32
	month::Int8
	day::Int8
end

"""
Time is stored as microseconds since 00:00:00
Use the duckdb_from_time/duckdb_to_time function to extract individual information
"""
struct duckdb_time
	micros::Int64
end

struct duckdb_time_struct 
	hour::Int8
	min::Int8
	sec::Int8
	micros::Int32
end

"""
Timestamps are stored as microseconds since 1970-01-01
Use the duckdb_from_timestamp/duckdb_to_timestamp function to extract individual information
"""
struct duckdb_timestamp 
	micros::Int64
end

struct duckdb_timestamp_struct 
	date::Ref{duckdb_date_struct}
	time::Ref{duckdb_time_struct}
end

struct duckdb_interval 
	months::Int32
	days::Int32
	micros::Int32
end

"""
Hugeints are composed in a (lower, upper) component
The value of the hugeint is upper * 2^64 + lower
For easy usage, the functions duckdb_hugeint_to_double/duckdb_double_to_hugeint are recommended
"""
struct duckdb_hugeint
	lower::UInt64
	upper::Int64
end

struct duckdb_blob 
	data::Cvoid
	size::UInt64
end

struct duckdb_column
	data::Ptr{Cvoid}
	nullmask::Ptr{UInt8}
    type::Ptr{DUCKDB_TYPE}
	name::Ptr{UInt8}
	internal_data::Ptr{Cvoid}
end

struct duckdb_result
	column_count::Ptr{UInt64}
	row_count::Ptr{UInt64}
	rows_changed::Ptr{UInt64}
	columns::Ptr{duckdb_column}
	error_message::Ptr{UInt8}
	internal_data::Ptr{Cvoid}
end

duckdb_types = (missing,UInt8,Int8,Int16,Int32,Int64,UInt8,UInt16,UInt32,UInt64,Float32,Float64,Int64,Int32,Int64,duckdb_interval,duckdb_hugeint,Ptr{UInt8},duckdb_blob)