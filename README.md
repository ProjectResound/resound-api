# Resound API

The backend that all of Resound's apps hook into.


## Getting Started
These instructions will get you a copy of the latest docker image and run the image
on your docker machine.

1. `docker pull scprdev/resound-api`
2. `docker run -d -p 80:3000 resound-api`

### Prerequisites

[Docker](https://www.docker.com/)


## Built With
* [Rails 5.0.0](http://rubyonrails.org/)
* [FFMPEG](http://ffmpeg.org) to transcode WAV to FLAC
* [Shrine 2.5.0](http://shrinerb.com/) for file uploading to S3
* [AWS S3](https://aws.amazon.com/s3/) for permanent file storage
