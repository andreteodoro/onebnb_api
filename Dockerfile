# Image base
FROM ruby:2.3-slim

# Install dependencies
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential nodejs libpq-dev imagemagick

# Set our path
ENV INSTALL_PATH /onebnb_api

# Create the directory
RUN mkdir -p $INSTALL_PATH

# Set out path as work directory
WORKDIR $INSTALL_PATH

# Copy the Gemfile into the container
COPY Gemfile Gemfile.lock ./

# Set the path to the gems
ENV BUNDLE_PATH /box

# Copy the code into the container
COPY . .
