# Resound API [![CircleCI](https://circleci.com/gh/ProjectResound/resound-api.svg?style=svg)](https://circleci.com/gh/ProjectResound/resound-api)
The backend that all of Resound's apps hook into. More info about the suite of apps [in the wiki](https://github.com/ProjectResound/planning/wiki)

## IMPORTANT NOTE!!
This is not a working branch. It's one example of how multi-tenancy would work using the [apartment gem](https://github.com/influitive/apartment).

Multi-tenancy would be handled on the API side (this repo).  Each group or station would be a separate tenant. For example, `kpcc` and `npr`.

To create the tenants, first you need to set the env variable `ALLOWED_CORS_URLS`.
Example: `ALLOWED_CORS_URLS=http://kpcc.resound.npr.org,http://why.resound.npr.org`

Then you can run the following rake task, that will create the tenants based on the urls
```
rake db:create_tenants
```

## Getting Started
These instructions will get you a copy of the latest docker image and run the image
on your docker machine.

1. `docker pull scprdev/resound-api`
2. `docker run -d -it -p 80:3000 scprdev/resound-api`

## Development
This rails app uses the [dotenv gem](https://github.com/bkeepers/dotenv). See `.env.example`

These steps will run the server for development:
1. Install Ruby
2. Install bundler
3. Install and run database
4. Create an .env file from .env.example
5. Create a secrets.yml from secrets.yml.example
6. `bundle exec rake db:create RAILS_ENV=test`
7. `bundle exec rake db:schema:load RAILS_ENV=test`
8. `bundle install`
9. `rails s`

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
