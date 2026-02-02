

## deal with iThing images

# example URL https://raw.githubusercontent.com/rswaty/meghalaya_pictures/main/images/goodbye_mqt.jpg


# ============================================================
# R Script: HEIC -> JPG -> Resize for StoryMapJS
# ============================================================

library(fs)
library(magick)

# -----------------------------
# CONFIG
# -----------------------------
img_dir  <- "images"     # folder containing HEIC files
max_dim  <- 2400         # maximum long edge for StoryMapJS
quality  <- 88           # JPEG quality
recursive <- TRUE        # find HEICs in subfolders too?

# -----------------------------
# 1. Find all HEIC files
# -----------------------------
heics <- dir_ls(img_dir,
                recurse = recursive,
                regexp = "\\.HEIC$|\\.heic$")

if (length(heics) == 0) {
  stop("No HEIC files found in ", img_dir)
}

message("Found ", length(heics), " HEIC files.")

# -----------------------------
# 2. Conversion + resize
# -----------------------------
for (heic_file in heics) {
  
  # Output JPG path (same folder, same basename)
  jpg_file <- path_ext_set(heic_file, "jpg")
  
  message("Converting: ", path_file(heic_file), " -> ", path_file(jpg_file))
  
  # ---- HEIC -> JPG using heif-convert ----
  tmp_file <- paste0(jpg_file, ".converted.jpg")
  res <- system2(
    "heif-convert",
    args = c(shQuote(heic_file), shQuote(tmp_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  if (!file_exists(tmp_file)) {
    warning("Conversion failed for ", heic_file, "\n", paste(res, collapse = "\n"))
    next
  }
  
  # Overwrite final JPG
  file_move(tmp_file, jpg_file)
  
  # ---- Resize for StoryMapJS ----
  img <- image_read(jpg_file)
  img <- image_resize(img, paste0(max_dim, "x", max_dim, ">"))
  image_write(img, jpg_file, quality = quality)
  
  message("Done: ", path_file(jpg_file))
}

message("All HEIC files converted and resized.")



## rotate an image -----

image_read("images/goodbye_mqt.jpg") |>
  image_rotate(-90) |>
  image_write("images/finn_and_pepper.jpg", quality = 88)




