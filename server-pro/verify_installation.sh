#!/bin/bash
   echo "==VERIFY INSTALLATION==";
   mkdir -p $DIAGNOSTIC_DIR
   chmod 777 $DIAGNOSTIC_DIR
   rstudio-server verify-installation --verify-user=$RSP_TESTUSER | tee $DIAGNOSTIC_DIR/verify.log