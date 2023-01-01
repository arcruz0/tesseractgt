#' Create "ground truth" .gt.txt files in a folder of images
#'
#' @param folder A path to a folder with images.
#' @param extension A file extension, e.g., "png". Also accepts regex, e.g., "png|tif".
#' @param engine A Tesseract engine, made with `tesseract::tesseract()`.
#'
#' @return Nothing. But .gt.txt "ground truth" files are created in the specified folder.
#' @export

create_gt_txt <- function(folder, extension, engine = NULL){

  image_files <- list.files(folder, full.names = T) |>
    stringr::str_subset(stringr::str_c("\\.", extension, "$"))

  text_files <- image_files |>
    stringr::str_replace(stringr::str_c("\\.", extension, "$"), ".gt.txt")

  for (i in 1:length(image_files)){

    if (!is.null(engine)){
      vector_ocr_i <- tesseract::ocr(image_files[i], engine = engine)
    } else {
      vector_ocr_i <- ""
    }

    writeLines(text = vector_ocr_i, con = text_files[i], sep = "")
  }

}
