using Test
using DataFrames, DBInterface, CSV, Dates
using DuckDB
#include("../src/DuckDB.jl")

@testset "DB Connection" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    @test isa(con, Base.RefValue{Ptr{Nothing}})
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "Appender API" begin
    # Open the database
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)

    # Create the table the data is appended to
    DuckDB.execute(con, "CREATE TABLE dtypes(bol BOOLEAN, tint TINYINT, sint SMALLINT, int INTEGER, bint BIGINT, utint UTINYINT, usint USMALLINT, uint UINTEGER, ubint UBIGINT, float FLOAT, double DOUBLE, date DATE, time TIME, vchar VARCHAR)")

    # Create the appender
    appender = DuckDB.appender_create(con, "main", "dtypes")

    # Append the different data types
    DuckDB.duckdb_append_bool(appender, true)
    DuckDB.duckdb_append_int8(appender, 1)
    DuckDB.duckdb_append_int16(appender, 2)
    DuckDB.duckdb_append_int32(appender, 3)
    DuckDB.duckdb_append_int64(appender, 4)
    DuckDB.duckdb_append_uint8(appender, 1)
    DuckDB.duckdb_append_uint16(appender, 2)
    DuckDB.duckdb_append_uint32(appender, 3)
    DuckDB.duckdb_append_uint64(appender, 4)
    DuckDB.duckdb_append_float(appender, 1.0)
    DuckDB.duckdb_append_double(appender, 2.0)
    DuckDB.duckdb_append_date(appender, 100)
    DuckDB.duckdb_append_time(appender, 200)
    DuckDB.duckdb_append_varchar(appender, "Foo")
    # End the row of the appender
    DuckDB.duckdb_appender_end_row(appender)
    # Destroy the appender and flush the data
    DuckDB.duckdb_appender_destroy(appender)

    # Retrive the data from the table and store it in  a vector
    df = DuckDB.toDataFrame(con, "select * from dtypes;")
    data = Matrix(df)

    # Test if the correct types have been appended to the table
    @test data[1] === true
    @test data[2] === Int8(1)
    @test data[3] === Int16(2)
    @test data[4] === Int32(3)
    @test data[5] === Int64(4)
    @test data[6] === UInt8(1)
    @test data[7] === UInt16(2)
    @test data[8] === UInt32(3)
    @test data[9] === UInt64(4)
    @test data[10] === Float32(1.0)
    @test data[11] === Float64(2.0)
    @test data[12] === Dates.Date("1970-04-11")
    @test data[13] === Dates.Time(0, 0, 0, 0, 200)
    @test data[14] === "Foo"

    # Disconnect and close the database
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "Test README" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(con, "CREATE TABLE integers(date DATE, jcol INTEGER)")
    res = DuckDB.execute(
        con,
        "INSERT INTO integers VALUES ('2021-09-27', 4), ('2021-09-28', 6), ('2021-09-29', 8)",
    )
    res = DuckDB.execute(con, "SELECT * FROM integers")
    @test isa(DuckDB.toDataFrame(res), DataFrame)
    @test isa(DuckDB.toDataFrame(con, "SELECT * FROM integers"), DataFrame)
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "HUGE Int test" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(con,"CREATE TABLE huge(id INTEGER,data HUGEINT);")
    res = DuckDB.execute(con,"INSERT INTO huge VALUES (1,NULL), (2, 1761718171), (3, 171661889178);")
    res = DuckDB.toDataFrame(con,"SELECT * FROM huge")
    DuckDB.disconnect(con)
    DuckDB.close(db)  
end

@testset "Interval type" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(con, "CREATE TABLE interval(interval INTERVAL);")
    res = DuckDB.execute(
        con,
        """
INSERT INTO interval VALUES 
(INTERVAL 5 HOUR),
(INTERVAL 12 MONTH),
(INTERVAL 12 MICROSECOND),
(INTERVAL 1 YEAR);
""",
    )
    res = DuckDB.toDataFrame(con, "SELECT * FROM interval;")
    @test isa(res, DataFrame)
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "Timestamp" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(con, "CREATE TABLE timestamp(timestamp TIMESTAMP , data INTEGER);")
    res = DuckDB.execute(
        con,
        "INSERT INTO timestamp VALUES ('2021-09-27 11:30:00.000', 4), ('2021-09-28 12:30:00.000', 6), ('2021-09-29 13:30:00.000', 8);",
    )
    res = DuckDB.execute(con, "SELECT * FROM timestamp;")
    res = DuckDB.toDataFrame(res)
    @test isa(res, DataFrame)
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "Items table" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(
        con,
        "CREATE TABLE items(item VARCHAR, value DECIMAL(10,2), count INTEGER);",
    )
    res = DuckDB.execute(
        con,
        "INSERT INTO items VALUES ('jeans', 20.0, 1), ('hammer', 42.2, 2);",
    )
    res = DuckDB.toDataFrame(con, "SELECT * FROM items;")
    @test isa(res, DataFrame)
    DuckDB.disconnect(con)
end

@testset "Integers and dates table" begin
    db = DuckDB.DB()
    res = DBInterface.execute(db, "CREATE TABLE integers(date DATE, data INTEGER);")
    res = DBInterface.execute( 
        db,
        "INSERT INTO integers VALUES ('2021-09-27', 4), ('2021-09-28', 6), ('2021-09-29', 8);",
    )
    res = DBInterface.execute(db, "SELECT * FROM integers;")
    res = DuckDB.toDataFrame(res)
    @test isa(res, DataFrame)
    DBInterface.close!(db)
end

@testset "Query CSV and output DataFrame" begin
    df = DataFrame(a=1:100, b=1:100)
    CSV.write("test_dataframe.csv", df)
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    df1 = DuckDB.toDataFrame(con, "SELECT * FROM 'test_dataframe.csv';")
    @test df == df1
    DuckDB.disconnect(con)
    DuckDB.close(db)
end

@testset "Export and Query Parquet" begin
    db = DuckDB.open(":memory:")
    con = DuckDB.connect(db)
    res = DuckDB.execute(con, "CREATE TABLE integers(date DATE, jcol INTEGER)")
    res = DuckDB.execute(con,
        "INSERT INTO integers VALUES ('2021-09-27', 4), ('2021-09-28', 6), ('2021-09-29', 8)")
    res = DuckDB.execute(con, "COPY (SELECT * FROM integers) TO 'test.parquet' (FORMAT 'parquet');")
    df1 = DuckDB.toDataFrame(con, "SELECT * FROM integers;")
    df2 = DuckDB.toDataFrame(con, "SELECT * FROM 'test.parquet';")
    @test df1 == df2
    DuckDB.disconnect(con)
    DuckDB.close(db)
end
