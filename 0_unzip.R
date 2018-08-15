setwd("/home/yangao/Documents/landsat7_mich/Bulk Order 931000")

comprimidos<-list.files(".", pattern = glob2rx("*.tar.gz"), full.names = TRUE)

for( i in 1:length(comprimidos)){
  folder<-substr(comprimidos[i], 3, 42)
  untar(comprimidos[i],exdir = folder)
}

