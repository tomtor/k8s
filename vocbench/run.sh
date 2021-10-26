#docker run -p 1979:1979 --name vocbench3-test -t vocbench3:10.1.0
docker run -v /data/vocbench:/opt/vocbench3/data -p 1979:1979 --name vocbench3-test -t vocbench3:10.1.0
