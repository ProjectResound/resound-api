# Resound API

The backend that all of Resound's apps hook into.  Currently, it only does 
one thing.  For quick setup:

1. `docker pull scprdev/resound-api`
2. `docker run -d -p 80:3000 resound-api`

That will download and run a container that contains the API. You will be
able to access the API from your docker-machine's IP.

## Upload
Clients upload chunks of files. Once the last chunk is received, Resound API
stitches the chunks together and transcodes it into FLAC.