# Needs to be run as an admin that has write permissions to /etc/rstudio
#
# This script when run against any R version will 
# * figure out which compatible BioConductor Version exist
# * get all the URLs for the repositories of BioConductor
# * output a Rprofile.site to stdout  

# OS flag for binaries (leave empty if not needed

binaryflag<-""

if(file.exists("/etc/debian_version")) {
    binaryflag <- "__linux__/focal"
}

if(file.exists("/etc/redhat-release")) {
    binaryflag <- "__linux__/centos7"
}

# Check if BiocManager is installed - needed to determine BioConductor Version
if ( ! "BiocManager" %in% utils::installed.packages() ) {
    Sys.setenv(R_PROFILE_USER = "/dev/null")
    system(paste("mkdir -p", Sys.getenv("R_LIBS_USER")))
    suppressMessages(utils::install.packages("BiocManager",quiet=TRUE,repos="https://cran.r-project.org/", lib=Sys.getenv("R_LIBS_USER")))
    Sys.unsetenv("R_PROFILE_USER")
  }
suppressMessages(library(BiocManager, lib.loc=Sys.getenv("R_LIBS_USER"),quietly=TRUE,verbose=FALSE))
# Get current repo settings
r <- getOption("repos")

# Package Manager URL
pm <- "https://packagemanager.rstudio.com"

# Version of BioConductor as given by BiocManager (can also be manually set)
suppressMessages(biocvers <- BiocManager::version())

# Bioconductor Repositories
suppressMessages(r<-gsub("https://bioconductor.org", paste0(pm,"/bioconductor/",binaryflag), BiocManager::repositories(version=biocvers)))

# CRAN repo
r["CRAN"] <- paste0(pm,"/cran/",binaryflag,"/latest/")

nr=length(r)
r<-c(r[nr],r[1:nr-1])


cat("local({\n")
cat('  r <- getOption("repos")\n')
ctr=0;for (i in names(r)) {ctr<-ctr+1;cat(paste0('  r["',i,'"]="',r[ctr],'"\n'))}
cat("  options(repos = r)\n")
cat("})\n")
