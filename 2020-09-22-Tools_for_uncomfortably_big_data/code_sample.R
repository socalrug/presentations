#' Uncomfortable data
#' LA R Users Group
#' 2020-09-22
#' Edward Visel

#' Setup
library(tidyverse)


path <- '/tmp/nycflights13/flights.csv'
dir.create(dirname(path))
data.table::fwrite(nycflights13::flights, file = path)


#####################################
### Demo 1: Subsetting strategies ###
#####################################

#' 1. Read then subset
flights <- read_csv(path)
small_1 <- flights %>% select(carrier, origin, dest, year, month, day, dep_time)

#' 2. Subset on read
small_2d <- data.table::fread(path, select = c('carrier', 'origin', 'dest', 'year', 'month', 'day', 'dep_time'))
small_2t <- read_csv(path, col_types = cols_only(
    carrier = col_guess(),
    origin = col_guess(),
    dest = col_guess(),
    year = col_guess(),
    month = col_guess(),
    day = col_guess(),
    dep_time = col_guess()
))

#' 3. Batch, subset, and aggregate

## Unknown file size
# setup
batch_size = 10000L
n = batch_size
offset = 0L
col_names <- names(read.csv(path, nrows = 1))
df_list <- list()

# iterate
while (n == 10000L) {
    # read
    message('Reading rows from ', offset, ' up to ', offset + batch_size)
    df <- read.csv(path, skip = offset, nrows = batch_size, col.names = col_names, stringsAsFactors = FALSE)

    # subset and append
    df_list[[length(df_list) + 1L]] <- df[c('carrier', 'origin', 'dest', 'year', 'month', 'day', 'dep_time')]

    # increment
    n <- nrow(df)
    offset <- offset + batch_size
}

# aggregate
small_3b <- do.call(rbind, df_list)


## Precalculating file size
batch_size <- 10000L
col_names <- names(read_csv(path, n_max = 0))
n_lines <- scan(
    text = system(paste('wc -l', path), intern = TRUE),
    what = integer(1),
    nmax = 1
)
offsets <- seq(1L, n_lines, by = batch_size)

small_3t <- map_dfr(offsets, function(offset){
    message('Reading rows ', offset, ' to ', min(offset + batch_size, n_lines))

    suppressMessages(
        read_csv(path, skip = offset, col_names = col_names, n_max = batch_size)
    ) %>%
        select(carrier, origin, dest, year, month, day, dep_time)
})


############################
### Demo 2: Storing data ###
############################

flights_dir <- '/tmp/flights'
data('flights', package = 'nycflights13')

flights %>%
    group_by(carrier, year, month) %>%
    nest() %>%
    mutate(
        filepath = file.path(flights_dir, carrier, year, sprintf('%02s.parquet', month))
    ) %>%
    pwalk(function(...) {
        dots <- list(...)
        if (!dir.exists(dirname(dots$filepath))) {
            dir.create(dirname(dots$filepath), recursive = TRUE)
        }

        arrow::write_parquet(
            dots$data, dots$filepath,
            version = '1.0', chunk_size = 10000L,
            compression = 'snappy'
        )
    })

list.dirs(flights_dir)

list.files(file.path(flights_dir, "AA", "2013"), full.names = TRUE)

system('tree /tmp/flights')


##############################
### Demo 3: Arrow Datasets ###
##############################

#' Single-file CSV Arrow Dataset

list.files('/tmp/nycflights13/')
flights_ds_c <- arrow::open_dataset('/tmp/nycflights13/', format = 'csv')

flights_ds_c
flights_ds_c$files
flights_ds_c$format
flights_ds_c$num_cols
flights_ds_c$num_rows

flights_ds_c %>%
    select(carrier, origin, dest, year, month, day, dep_time)

flights_ds_c %>%
    select(carrier, origin, dest, year, month, day, dep_time) %>%
    collect()

flights_ds_c %>%
    select(carrier, origin, dest) %>%
    filter(dest == 'LAX') %>%
    collect()


#' Multi-file, multi-directory Parquet Arrow Dataset

flights_ds_p <- arrow::open_dataset(flights_dir, partitioning = c('carrier', 'year'))

flights_ds_p
flights_ds_p$files
flights_ds_p$format
flights_ds_p$num_cols
flights_ds_p$num_rows

flights_ds_p %>%
    select(carrier, origin, dest, matches('time$')) %>%
    collect()

flights_ds_p %>%
    filter(carrier == 'UA', distance > 1000, !is.na(arr_delay)) %>%
    collect()


#' Limitations

flights_ds_p %>%
    group_by(carrier) %>%    # works
    filter(n() > 10000)    # most expressions beyond inequality like `n()` are not supported

flights_ds_p %>%
    # mutation (in `mutate`, `transmute`, or `group_by`) not supported
    mutate(arr_time = hms::hms(hours = arr_time %/% 100L, minutes = arr_time %% 100L))

flights_ds_p %>%
    group_by(carrier) %>%
    summarise(mean_arr_delay = mean(arr_delay))    # `summarise()` not supported


#' Demo 3 is in the accompanying shell script


########################
### Demo 4: sergeant ###
########################

library(sergeant)

#' DBI interface
dbi_con <- dbConnect(Drill())
DBI::dbGetQuery(dbi_con, 'SELECT * FROM dfs.tmp.`flights` LIMIT 3')

#' REST interface
rest_con <- drill_connection()
drill_query(rest_con, 'SELECT * FROM dfs.tmp.`flights` LIMIT 3')

#' dbplyr interface
tbl(dbi_con, 'dfs.tmp.`flights`')
#' or
drill <- src_drill()
tbl(drill, 'dfs.tmp.`flights`')


#' SQL translation
?drill_custom_functions
sql_translate_env(dbi_con)

flights_drill <- tbl(drill, 'dfs.tmp.`flights`') %>%
    mutate(
        carrier = dir0,
        year = dir1,
        # as.integer is translated; LEFT is passed through to Drill
        month = as.integer(LEFT(filename, 2L))
    )

flights_drill
flights_drill %>% show_query()

flights_drill %>% count()
flights_drill %>% count(carrier = dir0, sort = TRUE)
flights_drill %>% count(carrier = dir0, sort = TRUE) %>% collect()

flights_drill %>%
    filter(dest %in% c('LAX', 'ONT', 'SNA', 'BUR', 'LGB')) %>%
    group_by(carrier, origin, dest) %>%
    summarise(
        mean_arr_delay = mean(arr_delay),
        sd_arr_delay = sd(arr_delay),
        max_arr_delay = max(arr_delay),
        n = n()
    ) %>%
    arrange(mean_arr_delay) %>%
    collect()
