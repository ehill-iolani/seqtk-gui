# Set the base image; built on Ubuntu 22.04 jammy
FROM rocker/shiny

# My authorship
LABEL maintainer="ehill@iolani.org"
LABEL version="1.0.0"
LABEL description="AIN Seqtk Conversion GUI"

# Disable prompts during package installation
ENV DEBIAN_FRONTEND noninteractive

# Update the image
RUN apt update
RUN apt install -y nano git curl

# Install R packages
RUN R -e "install.packages(c('reticulate', 'shinycssloaders'))"

# Copy the app to the image
RUN rm -r /srv/shiny-server/*
RUN git clone https://github.com/ehill-iolani/seqtk-gui.git
RUN cp -r seqtk-gui/* /srv/shiny-server/
RUN rm -r seqtk-gui

# Conda/Mamba installation
RUN cd tmp
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh --output miniconda.sh
RUN bash miniconda.sh -bup /miniconda3
ENV PATH="/miniconda3/bin:$PATH"

# Install seqtk
RUN conda update -y conda && \
    conda init && \
    conda install -y -c bioconda seqtk && \
    rm /miniconda.sh

# Make /home/ writeable to all "users"
RUN chmod -R 777 /home/

# Make conda executable to all "users"
RUN chmod -R 777 /miniconda3/bin/*