#!/bin/sh
# Inspired from https://github.com/araines/serverless-php by Andy Raines
# This script builds a docker container, compiles PHP for use with AWS Lambda,
# and copies the final binary to the host and then removes the container.
#
# You can specify the PHP Version by setting the branch corresponding to the
# source from https://github.com/php/php-src

set -e

# TODO Make a `Makefile` and let us run this script using make
# The idea is to hide the details of all the tasks behind a single tool.
# The PHP version could be passed as a command argument instead of the variable below.

PHP_VERSION_GIT_BRANCH=php-7.2.5

echo "Build PHP Binary from current branch '$PHP_VERSION_GIT_BRANCH' on https://github.com/php/php-src"

docker build --build-arg PHP_VERSION=$PHP_VERSION_GIT_BRANCH -t php-build .

container=$(docker create php-build)

docker -D cp $container:/php-src-$PHP_VERSION_GIT_BRANCH/sapi/cli/php .
docker rm $container

tar czf $PHP_VERSION_GIT_BRANCH.tar.gz php
rm php
aws s3 cp $PHP_VERSION_GIT_BRANCH.tar.gz s3://bref-php/bin/
rm $PHP_VERSION_GIT_BRANCH.tar.gz
# TODO Automatically make the `.tar.gz` file public on AWS S3.
