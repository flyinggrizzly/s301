# S301

#### An S3 and Cloudfront based URL shortener.

S301 is intended to be a lightweight, fast, and resilient URL shortener. It uses AWS' S3 and Cloudfront in ways typically intended for hosting static websites, to expose redirects at any Cloudfront edge location.

The Rails app manages all known short URLs, and when changes are made, they are published out to an S3 bucket, and the Cloudfront cache is invalidated. Instead of static HTML objects being stored in the S3 bucket, S301 stores itty-bitty files with two important pieces of information: the name, which is your short URL slug, and an [`x-amz-website-redirect-location` metadatum](https://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html#how-to-page-redirect), which is interpreted as the destination in a 301 redirect.

This has a few cool implications:

- users requesting shortened URLs don't have to wait for database queries to run--they're effectively getting a 301 redirect the minute they hit the Cloudfront edge location
- if the Rails app goes down, your URL shortening service can still serve users
  - and if you're running this personally, on, say, Heroku's free tier, you don't have to worry about uptime

## Rails setup

You'll need to set a few values in some initializes before you get going:

- your shortened URL host (required for validations to avoid endless loop redirects--you don't want to redirect to this host), in `config/initalizers/app_host.rb`
- (optional) any restricted slugs (`index` and `unknown-short-url` should always be restricted because they provide special app behavior), in `config/initializers/reserved_slugs.rb`


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

### S3 gotchas

The AWS publisher works pretty well, but there is a little bit of brittleness in that it is not currently possible to update a short URL that hasn't been pushed to S3.

The S3 PUT action differs for new and existing objects (I know...), and the ShortUrl::publish action calls a different method in the publisher service based on whether or not the `created_at` and `updated_at` attributes on a short URL object differ.

If they differ, it will call an S3 PUT/Copy action, but this will fail if there is no object in S3 to copy from. (It's been done this way to reduce the HTTP requests made to AWS, but there are limitations... and this is a candidate for change). This *will* cause a Rails error

If you run into these in development, the easiest thing to do is pull up the console and destroy the short URL in the database, then recreate it in the app.

This pretty much only ever comes up if you've been working with the database before adding the S3 bucket to the mix, but it would also be an issue in production if the first PUT request to S3 failed.

There isn't yet an S3 destroy method. That's coming.

### Cloudfront gotcha

If you find that your cloudfront distro isn't showing accurately what's in the S3 bucket, you probably need to invalidate the cache for either the single resource, or the whole thing:

```bash
rake cloudfront:invalidate RESOURCE=object_name
rake cloudfront:invalidate_all
```

## Contributing

Please do! Right now, most tasks are in the [todo file](/todo.md), but also feel free to open an issue, or make a PR! If you're picking up work that isn't in an issue or the todo file, hit me up first!
