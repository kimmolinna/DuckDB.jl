import DuckDB
con = DuckDB.connect(":memory:")
res = DuckDB.execute(con,"CREATE TABLE ca_sr AS SELECT * FROM read_csv_auto('/home/kimmo/pluto/csv/test.csv');")
res = DuckDB.execute(con,"SELECT * from ca_sr;")
res = DuckDB.toDataFrame(res)

res = DuckDB.execute(con,"CREATE TABLE integers(date DATE, jcol INTEGER);")
res = DuckDB.execute(con,"INSERT INTO integers VALUES ('2021-09-27', 4), ('2021-09-28', 6), ('2021-09-29', 8);")
res = DuckDB.execute(con,"SELECT * FROM integers;")
res = DuckDB.toDataFrame(res)

res = DuckDB.execute(con, "CREATE TABLE items(item VARCHAR, value DECIMAL(10,2), count INTEGER);")
res = DuckDB.execute(con, "INSERT INTO items VALUES ('jeans', 20.0, 1), ('hammer', 42.2, 2);")
res = DuckDB.execute(con, "SELECT * FROM items;")
res = DuckDB.toDataFrame(res)