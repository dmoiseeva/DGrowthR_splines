install.packages("DGrowthR")

library("tidyverse")
library(devtools)
# We also need the permApprox package for the permutation test in the growth comparison section
# Here we install if it wasn't already installed
if(!requireNamespace("permApprox", quietly = TRUE)) {
  remotes::install_github("stefpeschel/permApprox")
}
# Read example data from Brenzinger 2024
example_brenzinger <- read.delim("../Source_Data/Brenzinger_2024/od_data/wt_1_OD.txt",
                                 sep = '\t')

tibble(example_brenzinger) %>%
  rmarkdown::paged_table()
# Create common time vector
common_time_vector <- c(0, 2, seq(from=2.739, by=0.739, length.out=18))

# Read all OD data
brenzinger_data <- read_multiple_plates(path_target = "../Source_Data/Brenzinger_2024/od_data/",
                                        time_vector = common_time_vector)
#> The following OD data was found: dCBASS_1_OD.txt, dCBASS_2_OD.txt, dCBASS_3_OD.txt, wt_1_OD.txt, wt_2_OD.txt, wt_3_OD.txt
# Show the first five columns of the complete OD data
brenzinger_od <- brenzinger_data[["od_data"]]


brenzinger_od %>%
  rmarkdown::paged_table()


brenzinger_metadata <- brenzinger_data[["metadata"]]


brenzinger_metadata %>%
  rmarkdown::paged_table()


# Information about each plate
database.df <- read_tsv("../Source_Data/Brenzinger_2024/Database.txt",
                        show_col_types = FALSE) %>%
  separate(Strain, into = c("genotype", NA)) %>%
  select(file_id, genotype, Rep_Nr) %>%
  mutate(plate_name = tools::file_path_sans_ext(file_id))

# Information about each well
mapper.df <- read_tsv("../Source_Data/Brenzinger_2024/Map.txt",
                      show_col_types = FALSE) %>%
  rename("well" = "Well")


# Add this information to the metadata data frame
brenzinger_metadata <- brenzinger_metadata %>%
  left_join(database.df, by="plate_name") %>%
  left_join(mapper.df, by="well") %>%
  unite("genotype_well", c(genotype, well), sep="_", remove=FALSE)

brenzinger_metadata %>%
  rmarkdown::paged_table()


# Instantiate a DGrowthR object
dgobj <- DGrowthRFromData(od_data = brenzinger_od,
                          metadata = brenzinger_metadata)

plot_growth_curves(dgobj)


plot_growth_curves(dgobj, facet="plate_name", color="genotype")


dgobj <- preprocess_data(dgobj)


plot_growth_curves(dgobj, facet="plate_name", color="genotype")


dgobj <- estimate_fpca(dgobj)
dgobj <- estimate_umap(dgobj)


plot_fpca(dgobj)



plot_umap(dgobj)
