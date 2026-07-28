# DuckDB Reference

A refresher for this dotfiles duckdb setup. Config: `.duckdbrc`, symlinked to
`~/.duckdbrc` by `install.sh`.

> duckdb is an in-process analytical database. Here it's used as a *tabular-data
> CLI*: point a SQL query at a csv/tsv/json/parquet/xlsx file on disk and get
> answers, no import step and no server.

The init file applies to `duckdb -c "..."` too, not just the interactive REPL —
so scripts and one-liners get the same defaults.

## What `.duckdbrc` sets

| Line | Effect |
|---|---|
| `.startup_text none` | Silences the startup banner. **Must be the literal first line** — anything before it (even a comment) triggers a `should be on top of your ~/.duckdbrc` warning on *every* run |
| `.maxrows 20` | Default is 40; 20 fits a zellij pane |
| `.thousand_sep ,` | `1234567` renders as `1,234,567` |
| `.nullvalue NULL` | Distinguishes a genuine NULL from an empty string — with the default both render as blank |
| `.timer on` | Prints query wall time |
| `-- LOAD excel;` | Commented out. Uncomment to enable Excel *writes* — see [Excel writes](#excel-writes) |

Dot-commands take the rest of the line as their argument, so a trailing
`-- comment` is parsed as part of the value and errors out. Keep comments on
their own lines.

## First look at an unfamiliar file

`SUMMARIZE` is a better opening move than `SELECT *` — it profiles every column
in one shot instead of showing you 20 arbitrary rows:

```sql
SUMMARIZE SELECT * FROM 'data.parquet';
```

Returns `column_name`, `column_type`, `min`, `max`, `approx_unique`, `avg`,
`std`, `q25`, `q50`, `q75`, `count`, `null_percentage`.

For schema only, skip the stats:

```sql
DESCRIBE SELECT * FROM 'data.csv';
```

## Bare-path reads

A quoted path in `FROM` works directly for csv, tsv, ndjson, and parquet —
duckdb dispatches on the extension. No `INSTALL`/`LOAD` needed;
`autoload_known_extensions` is on by default.

```sql
SELECT * FROM 'trips.csv';
SELECT * FROM 'events.ndjson';
SELECT count(*) FROM 'part-*.parquet';   -- globs work too
```

From the shell:

```bash
duckdb -c "SUMMARIZE SELECT * FROM 'trips.csv'"
```

## Excel

### Reading — mind the header default

`read_xlsx()` defaults to `header=false`. A spreadsheet whose first row is column
names therefore comes back with columns literally named `A1`, `B1`, `C1`, and
`double` types inferred from the header row's text:

```sql
DESCRIBE SELECT * FROM read_xlsx('report.xlsx');
-- A1  double
-- B1  varchar
```

Pass `header=true` to treat the first row as column names instead:

```sql
SELECT * FROM read_xlsx('report.xlsx', header=true);
```

A bare `FROM 'report.xlsx'` gives you nowhere to put that option, so prefer the
explicit `read_xlsx()` form for spreadsheets.

### Excel writes

Read paths autoload on demand, but the `COPY … TO … (FORMAT xlsx)` *write* path
does not. Out of the box it fails with a misleading error:

```
Catalog Error: Copy Function with name xlsx does not exist! Did you mean "csv"?
```

The error names `csv`, not the missing extension — so it reads like the format is
unsupported rather than unloaded. The fix is `LOAD excel;`:

```sql
LOAD excel;
COPY (SELECT * FROM 'trips.csv') TO 'trips.xlsx' (FORMAT xlsx);
```

`.duckdbrc` carries that line **commented out** — writing Excel isn't a primary
use here, and loading the extension on every invocation isn't worth it. Run
`LOAD excel;` for the session when you need it, or uncomment the line in
`.duckdbrc` if it becomes routine.

## Escape hatches

| Need | Command |
|---|---|
| Silence the timer for one run (clean output for scripting) | `duckdb -c ".timer off" -c "SELECT …"` |
| Ignore `~/.duckdbrc` entirely | `duckdb -no-init` |
| Use a different init file | `duckdb -init path/to/rc` |

There is no `-norc` flag — it's `-no-init`.

## Truncation is honest

With `.maxrows 20`, a larger result set tells you what it withheld rather than
silently cutting off:

```
100 rows
(20 shown)
```
