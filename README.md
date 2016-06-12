# Heroku Haskell Stack Docker Image

An image for deploying Haskell/Stack applications to Heroku.

## Usage

Create your own `Dockerfile` inheriting from this image:

```
FROM thoughtbot/heroku-haskell-stack
```

Create a `stack-bootstrap` file containing large dependencies for your
application. For example:

```
alex classy-prelude-yesod happy yesod-bin yesod
```

These dependencies will be installed in their own Docker layer, so changing your
cabal file will not cause them to be reinstalled every time.

Build your image:

```
docker build .
```

Here's a sample `bin/deploy` script you can use in your Heroku project, assuming
you already have the heroku-docker Heroku plugin installed:

```sh
#!/bin/sh

set -e

if [ $# -ne 1 ]; then
  echo "Usage: ./bin/deploy (staging|production)"
  exit 1
fi

if [ $(uname) = "Darwin" ]; then
  eval "$(docker-machine env default)"
fi

heroku docker:release --remote "$1"
heroku open --remote "$1"
```

## Running a script before building

Many applications need to do something before running the actual Stack
build, such as compiling CSS. You can put commands in `bin/pre-build` and this
Dockerfile will run them before building the application.
