In [Writing custom controls to check spreadsheet integrity](https://steampipe.io/blog/spreadsheet-integrity) we show an example based on these files. To run it for yourself:

1. `steampipe plugin install csv`

2. Edit `~/.steampipe/config/csv.spc`, refer to this directory, e.g:

    -  `paths = [ "~/steampipe-samples/spreadsheet-integrity" ]`

3. Run `steampipe query`, then:

    -  `.inspect csv` to check that the tables exist

   - `select * from csv.people`

    - `select * from csv.sessions`

4. `steampipe check control.sessions_valid_in_session_table`

5. `steampipe check control.sessions_valid_in_people_table`

6. `steampipe check all`

7. `steampipe check all --export event_planning.html`