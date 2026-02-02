

## deal with iThing images

# example URL https://raw.githubusercontent.com/rswaty/meghalaya_pictures/main/images/finn_and_pepper.jpg


#install.packages("magick")
library(fs)
library(magick)

# deal with images renamed .jpg, but are not really jpps
jpgs <- dir_ls("images", regexp = "\\.jpg$", recurse = FALSE)

file_type <- function(f) {
  system2("file", args = c("-b", shQuote(f)), stdout = TRUE)
}

types <- vapply(jpgs, file_type, character(1))

heic_disguised <- jpgs[grepl("HEIF|HEIC", types, ignore.case = TRUE)]

heic_disguised
length(heic_disguised)

#convert the false .jpgs

library(fs)

for (f in heic_disguised) {
  
  tmp <- paste0(f, ".converted.jpg")
  
  res <- system2(
    "heif-convert",
    args = c(shQuote(f), shQuote(tmp)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  if (file_exists(tmp)) {
    file_move(tmp, f)  # overwrite the fake jpg with a real jpg
    message("Converted: ", path_file(f))
  } else {
    warning("Failed: ", f, "\n", paste(res, collapse = "\n"))
  }
}


# resize for storymaps

imgs <- dir_ls("images", regexp = "\\.jpg$")

for (f in imgs) {
  image_read(f) |>
    image_resize("2400x2400>") |>
    image_write(f, quality = 88)
}

## for true .heic

library(fs)
library(magick)

convert_heic_to_jpg <- function(
    heic_file,
    max_dim = 2400,
    quality = 88
) {
  stopifnot(file_exists(heic_file))
  stopifnot(tolower(path_ext(heic_file)) == "heic")
  
  # Output JPG path (same folder, same base name)
  jpg_file <- path_ext_set(heic_file, "jpg")
  
  # ---- HEIC -> JPG (via libheif) ----
  res <- system2(
    "heif-convert",
    args = c(shQuote(heic_file), shQuote(jpg_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  if (!file_exists(jpg_file)) {
    stop(
      "HEIC conversion failed for ", heic_file, "\n",
      paste(res, collapse = "\n")
    )
  }
  
  # ---- Resize for StoryMapJS ----
  img <- image_read(jpg_file)
  img <- image_resize(img, paste0(max_dim, "x", max_dim, ">"))
  image_write(img, jpg_file, quality = quality)
  
  invisible(jpg_file)
}


## rotate an image -----

image_read("images/finn_and_pepper.jpg") |>
  image_rotate(-90) |>
  image_write("images/finn_and_pepper.jpg", quality = 88)




