DEPLOY=/data/pythonapp/public/DT/Apps

all: build deploy


build:
	python3 build.py
	sh tiles.sh
 
deploy:
	cp DT.html 3d.html $(DEPLOY)
	cp 3d/* $(DEPLOY)/../data/3d
