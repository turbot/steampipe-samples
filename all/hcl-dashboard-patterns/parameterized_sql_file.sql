select 'parameterized sql file: ' || $1 as data

-- but this will fail, yielding -> parameterized sql file: $1
--select 'parameterized sql file: $1' as data