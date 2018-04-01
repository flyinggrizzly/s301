# S301

#### A static short URL generator for AWS S3 and CloudFront 

[![security](https://hakiri.io/github/flyinggrizzly/s301/master.svg)](https://hakiri.io/github/flyinggrizzly/s301/master)
[![Test coverage](https://codeclimate.com/github/flyinggrizzly/s301/badges/coverage.svg)](https://codeclimate.com/github/flyinggrizzly/s301/coverage)
[![Code Climate](https://codeclimate.com/github/flyinggrizzly/s301/badges/gpa.svg)](https://codeclimate.com/github/flyinggrizzly/s301)
[![Build Status](https://travis-ci.org/flyinggrizzly/s301.svg?branch=master)](https://travis-ci.org/flyinggrizzly/s301)

S301 is intended to be a lightweight, fast, and resilient URL shortener. It uses AWS' S3 and Cloudfront in ways typically intended for hosting static websites, to expose redirects at any Cloudfront edge location.

The Rails app manages all known short URLs, and when changes are made, they are published out to an S3 bucket, and the Cloudfront cache is invalidated. Instead of static HTML objects being stored in the S3 bucket, S301 sends a message to its publisher service with two important pieces of information: the short URL slug and redirect. The service then updates the [routing rules](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-websiteconfiguration-routingrules-redirectrule.html) of the bucket to include all known short URLs as redirects. It also makes a call to Cloudfront to invalidate the cache for the given slug.

This has a few cool implications:

- users requesting shortened URLs don't have to wait for database queries to run--they're effectively getting a 301 redirect the minute they hit the Cloudfront edge location
- if the Rails app goes down, your URL shortening service can still serve users
  - and if you're running this personally, on, say, Heroku's free tier, you don't have to worry about uptime

## Configuration

Most of the app config is done through the environment. [`dotenv-rails`](https://rubygems.org/gems/dotenv-rails/versions/2.1.1) is installed, so you can put all of these in a `.env` file.

The following environemnt variables are *required* (the AWS ones are discussed in a little more detail in the next section):

- `ENDPOINT`; defines your app's endpoint for shortened URLs (bitly's endpoint would be `https://bit.ly`)
- `AWS_S3_BUCKET_NAME`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

The following env vars are optional:

- `AWS_CLOUDFRONT_DISTRO_ID`
- `AWS_REGION` this is only required if your S3 bucket is in a region other than Virginia/us-east-1
- `RESERVED_SLUGS` allows you to reserve slugs in addition to the two reserved by the app(`index` and `unknown-short-url`), which will prevent them from being used by short URLs. The value for this env var should be a comma-separated list of slugs: `RESERVED_SLUGS="foo,bar,baz"`. Slugs must consist of only the characters a-z (case insensitive), numerals, and '-' or '_'

## AWS Setup

Before you start up the Rails app, there are a few things that need to be set up on AWS first:

1. an S3 bucket to use for your redirects. Technically, Cloudfront is an optional part of this, but if you skip Cloudfront, this bucket **must** have the name of your domain to be used for the shortening service (for example, a service like grz.li would need a bucket named "grz.li"). The bucket name will need to go into your app's environment as `AWS_S3_BUCKET_NAME`
2. a Cloudfront distro. Keep track of its ID, and set that in your app's environment as `AWS_CLOUDFRONT_DISTRO_ID`
3. an IAM user with credentials to manage your S3 bucket and Cloudfront distro. These credentials will also need to go into your environment as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. This IAM user should have a policy like this:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudfront:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::BUCKET_NAME"
                "arn:aws:s3:::BUCKET_NAME/*"
            ]
        }
    ]
}`
```

## Running and testing the app

- create the databases: `bin/rails db:create; bin/rails db:migrate`
- running tests: `bundle exec rspec; bundle exec cucumber`
- run the app: `bin/rails s`

### Cloudfront gotcha

If you find that your cloudfront distro isn't showing accurately what's in the S3 bucket, you probably need to invalidate the cache for either the single resource, or the whole thing:

```bash
rake cloudfront:invalidate RESOURCE=object_name
rake cloudfront:invalidate_all
```

## Contributing

Please do! If you want to pick an issue and make a PR, go for it! But also feel free to open an issue for anything you think would be good or useful. If you're picking up work that isn't in an issue, [hit me up](mailto:say-hi@grz.li) first!
