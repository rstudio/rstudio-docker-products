package main
import "github.com/baobabus/gcfg"
import "os"

func main(){
	ConnectConfig()
}

func ConnectConfig(){
// Declare sections and variables that should exist in the gcfg file
	data := struct {
      Server, HTTP, Authentication, Python, RPackageRepository map[string]*struct {
      	SenderEmail string
      	Address string
	  	  DataDir string
	  	  Listen string
	  	  Provider string
	  	  Enabled string
	  	  Executable string
	  	  URL string
	    }
  }{}
// Read in gcfg file producing an error if there are extra variables or sect
  err := gcfg.ReadFileInto(&data, "/etc/rstudio-connect/rstudio-connect.gcfg")
  
  if err != nil{
    panic(err)
  }
  os.Exit(0)
}
