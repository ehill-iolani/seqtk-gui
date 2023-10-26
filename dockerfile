# Set the base image; built on Ubuntu 22.04 jammy
FROM rocker/shiny

# My authorship
LABEL maintainer="ehill@iolani.org"
LABEL version="1.0.0"
LABEL description="AIN Seqtk Conversion GUI"

# Disable prompts during package installation
ENV DEBIAN_FRONTEND noninteractive

# Update the image, it
RUN apt update
RUN apt install -y nano git

# Install R packages
RUN R -e "install.packages(c('reticulate'))"

# Copy the app to the image
RUN rm -r /srv/shiny-server/*
RUN git clone https://github.com/ehill-iolani/epi2meviz.git
RUN cp -r epi2meviz/* /srv/shiny-server/
RUN rm -r epi2meviz