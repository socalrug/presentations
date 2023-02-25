library(tidyverse)

sets <- readr::read_csv("~/Desktop/sets.csv.gz")
inventories <- readr::read_csv("~/Desktop/inventories.csv.gz")
inventory_parts <- readr::read_csv("~/Desktop/inventory_parts.csv.gz")
parts <- readr::read_csv("~/Desktop/parts.csv.gz")
colors <- readr::read_csv("~/Desktop/colors.csv.gz")

inventory_parts_list <- inventory_parts |>
  select(inventory_id, part_num, color_id) |>
  left_join(parts |> rename(part_name = name), by = "part_num") |>
  left_join(colors |> rename(color_name = name), by = c("color_id" = "id")) |>
  select(-color_id, -part_num) |>
  nest(info = -c(inventory_id, part_name)) |>
  mutate(info = map(info, as.list)) |>
  nest(parts = -inventory_id) |>
  mutate(parts = map(parts, \(x) setNames(x$info, x$part_name)))

lego_sets <- sets |>
  inner_join(inventories, multiple = "all", by = "set_num") |>
  inner_join(inventory_parts_list, by = c("id" = "inventory_id")) |>
  filter(lengths(parts) > 0) |>
  select(-img_url, -version, -id) |>
  nest(info = -set_num) |>
  mutate(info = map(info, as.list))

lego_sets <- set_names(lego_sets$info, lego_sets$set_num)

jsonlite::write_json(lego_sets[1:100], "lego_sets.json")
