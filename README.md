Argus docker container with python pre installed.

Uses buster:slim as base.

//STEPS:

git clone https://github.com/deveshmanish/argus.git

cd argus

docker build .

docker tag <image id> <images name>:version

docker-compose up -d


//For Troubleshoot

//to retrive image id
docker ps -a 

//to login in image console

docker exec -it <image id> bash
