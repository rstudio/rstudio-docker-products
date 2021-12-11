VERSION=0.2
docker build -f Dockerfile . -t r-session-complete:${VERSION}-bionic
docker run -d -p 5000:5000 --restart=always --name registry registry:2
docker tag r-session-complete:${VERSION}-bionic localhost:5000/r-session-complete:${VERSION}-bionic 
docker push localhost:5000/r-session-complete:${VERSION}-bionic 
export TMP=/efs/tmp
export TEMP=$TMP
export TMPDIR=$TMP
export TEMPDIR=$TMP
export SINGULARITY_NOHTTPS=1
/efs/singularity/3.8.5/bin/singularity build /efs/singularity/containers/r-session-complete.img test.sdef 

