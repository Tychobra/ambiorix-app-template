FROM rocker/r-ver:4.3.2

# install system dependencies
RUN apt-get update -qq && apt-get install -y \
  curl \
  git-core \
  libssl-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  libpq-dev \
  libsodium-dev \
  gnupg2

RUN R -e "install.packages('remotes')"

RUN R -e "remotes::install_github('merlinoa/ambiorix', ref = '2552c879865a639810347bb4a553ca328a1896ab')"
RUN R -e "remotes::install_version('dbplyr', version = '2.3.2', upgrade = 'never')"
RUN R -e "remotes::install_version('dplyr', version = '1.1.1', upgrade = 'never')"
RUN R -e "remotes::install_version('glue', version = '1.6.2', upgrade = 'never')"
RUN R -e "remotes::install_version('httr', version = '1.4.7', upgrade = 'never')"
RUN R -e "remotes::install_version('jsonlite', version = '1.8.7', upgrade = 'never')"
RUN R -e "remotes::install_version('pool', version = '1.0.1', upgrade = 'never', quiet = FALSE)"
RUN R -e "remotes::install_version('RPostgres', version = '1.4.5', upgrade = 'never', quiet = FALSE)"
RUN R -e "remotes::install_version('tibble', version = '3.2.1', upgrade = 'never', quiet = FALSE)"
RUN R -e "remotes::install_version('uuid', version = '1.1-1', upgrade = 'never', quiet = FALSE)"
RUN R -e "remotes::install_version('tidyr', version = '1.3.0', upgrade = 'never', quiet = FALSE)"

VOLUME /app

COPY ./app /app

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["Rscript", "./server.R"]
