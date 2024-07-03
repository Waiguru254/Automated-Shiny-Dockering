#install.packages('glue','readr')
library(readr)
library(glue)
write_docker <- function(port, install_pack = '#', packages = unique(renv::dependencies('.')$Package) ) {
  #### Initialize the list of commands
  shiny_files <- c()
  ### Creating the shiny image in docker
  shiny_files[1] <-  'FROM rocker/shiny:latest'
  ### Creating the list of packages that is needed for the project
  shiny_files[2] <- paste(install_pack,'RUN R -e "install.packages(c(',paste0("'", 
                                                                              paste(paste(packages, collapse="', '"),
                                                                                    collapse="','"), "'"), collapse = "", "",'), dependencies = TRUE)"',sep = "")
  ## Changing the directory of the project
  shiny_files[3] <-  'RUN mkdir /home/shiny-app'
  i<- 4
  for (file in c(list.files(all.files = TRUE))) {
    ### Remove files that may that likely currently being used (Not possible to copy this)
    if (!grepl('.Rhistory|.Rprofile|.Rproj.user|.Rproj|Dockerfile', file) & file != '.' & file != '..') {
      shiny_files[i] <- paste('COPY ',file, ' /home/shiny-app/',file, sep = '')
      i <- i+1
    }
  }
  shiny_files[i]  <- glue::glue("EXPOSE {port}")
  shiny_files[i+1] <- paste('CMD ["R", "-e", "shiny::runApp(',"'/home/shiny-app',", "host = '0.0.0.0', port = ",port,')"]', sep = '')
  ### Creating the command(Exporting the dockerfile)
  readr::write_lines(shiny_files, file = file.path("Dockerfile"))
}
write_docker(port = 2222,install_pack = '', packages = c('dplyr', 'ggplot2', 'gapminder'))
