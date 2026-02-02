

library(fs)

# Repo info
repo_user <- "rswaty"
repo_name <- "meghalaya_pictures"
branch    <- "main"
img_dir   <- "images"

# List all JPGs in the folder
imgs <- dir_ls(img_dir, regexp = "\\.jpg$", recurse = TRUE)

# Build raw URLs
raw_urls <- paste0(
  "https://raw.githubusercontent.com/",
  repo_user, "/", repo_name, "/", branch, "/",
  imgs
)

raw_urls
