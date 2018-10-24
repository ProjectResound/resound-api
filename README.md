# Resound API [![CircleCI](https://circleci.com/gh/ProjectResound/resound-api.svg?style=svg)](https://circleci.com/gh/ProjectResound/resound-api)

The backend that all of Resound's apps hook into. More info about the suite of apps [in the wiki](https://github.com/ProjectResound/planning/wiki)


## Getting Started
These instructions will get you a copy of the latest docker image and run the image
on your docker machine.

1. `docker pull scprdev/resound-api`
2. `docker run -d -it -p 80:3000 scprdev/resound-api`

## Development
This rails app uses the [dotenv gem](https://github.com/bkeepers/dotenv). See `.env.example`

These steps will run the server for development:
1. Install Ruby
1. Install bundler
1. Install and run database
1. Create an .env file from .env.example
1. Create a secrets.yml from secrets.yml.example
1. `rake db:test:prepare`
1. `bundle install`
1. `rails s`

## Postgres setup
Resound API works with Postgres out of the box.

## MySQL setup
Resound is also designed to work with a MySQL database, although it loses some of the full text search capabilities, so search may be slower.

To run Resound API with the MySQL adapter, edit `database.yml` appropriately. Also comment
out the Scenic gem `gem 'scenic', '~> 1.4.0'` from the Gemfile befure running `bundle install`

## Upload via FTP
It is possible to configure `resound-api` to upload via FTP:
1. Copy `shrine_ftp_.rb.example` to `shrine.rb` in the `config/initializers` directory
2. Either fill in your FTP credentials in this new `shrine.rb` or pass them in as the environment variables.

### Required environment variables for FTP:
* RESOUND_FTP_HOST=ftp.somesite.com
* RESOUND_FTP_USER=ftpusername
* RESOUND_FTP_PASSWD=ftppassword
* RESOUND_FTP_DIR=optional_directory

### Prerequisites

[Docker](https://www.docker.com/)


## Built With
* [Rails 5.0.0](http://rubyonrails.org/)
* [FFMPEG](http://ffmpeg.org) to transcode WAV to FLAC
* [Shrine 2.5.0](http://shrinerb.com/) for file uploading to S3
* [AWS S3](https://aws.amazon.com/s3/) for permanent file storage
