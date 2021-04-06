#FROM docker.io/ashish1981/s390x-ubuntu-r-base:master-20201023-151448-76
FROM docker.io/ashish1981/r-ver:test
ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2020-04-24}
ENV LD_LIBRARY_PATH=/usr/lib/jvm/default-java/lib/server:/usr/lib/jvm/default-java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV R_VERSION=${R_VERSION:-3.6.3} \
    # CRAN=${CRAN:-https://cran.rstudio.com} \ 
    CRAN=${CRAN:-https://cloud.r-project.org} \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN apt-get update && apt-get install -y \
    apt-utils \
    libxml2-dev \
    libudunits2-dev

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget 

RUN apt-get update && apt-get install -y \
    liblzma-dev \
    libbz2-dev \
    clang  \
    ccache  \
    zlib1g \
    zlib1g-dev 
   

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-11-jre \
    && unset JAVA_HOME \
    && sudo R CMD javareconf   

RUN apt-get update && apt-get install -y \
    supervisor \
    git-core \
    libsodium-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libudunits2-dev \
    libmariadbclient-dev \
    xtail && \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x && \
    export PATH=$JAVA_HOME/bin/:$PATH && \
    export LD_LIBRARY_PATH=/usr/lib/jvm/default-java/lib/server:/usr/lib/jvm/default-java && \
    setarch s390x R CMD javareconf

## Add a library directory (for user-installed packages)
# RUN mkdir -p /usr/local/lib/R/site-library \
#     # && chown root:staff /usr/local/lib/R/site-library \
#     && chmod g+ws /usr/local/lib/R/site-library \
#     ## Fix library path
#     && sed -i '/^R_LIBS_USER=.*$/d' /usr/local/lib/R/etc/Renviron \
#     && echo "R_LIBS_USER=\${R_LIBS_USER-'/usr/local/lib/R/site-library'}" >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
#     ## Set configured CRAN mirror
    # if [ -z "$BUILD_DATE" ]; then MRAN=$CRAN; \
    # else MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE}; fi \
    # && echo MRAN=$MRAN >> /etc/environment \
    # && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
    ## Use littler installation scripts
#  RUN R -e "install.packages(c('docopt'), dependencies = TRUE, repo = '$CRAN')" \
#     ## Use littler installation scripts
#     && R -e "install.packages(c('littler'), dependencies = TRUE, repo = '$CRAN')" \
#     # && R -e "install.packages(c('plumber', 'RJDBC', 'rJava', 'DBI', 'dplyr'), dependencies = TRUE, repo = '$CRAN')" \
#     && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
#     && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
#     && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
#     # Clean up from R source install
#     && cd / \
#     && rm -rf /tmp/* \
#     # && apt-get remove --purge -y $BUILDDEPS \
#     # && apt-get autoremove -y \
#     # && apt-get autoclean -y \
#     && rm -rf /var/lib/apt/lists/*
# # Download and install R modules

RUN install2.r  rJava
RUN install2.r  RJDBC
RUN install2.r  shiny
RUN install2.r  shinydashboard
RUN install2.r  curl
RUN install2.r  httr
RUN install2.r  jsonlite
RUN install2.r  DT
RUN install2.r  shinyalert
RUN install2.r  stringr
RUN install2.r  dplyr
RUN install2.r  plotly
RUN install2.r  rmarkdown
RUN install2.r  leaflet
RUN install2.r  htmlwidgets
RUN install2.r  data.table
RUN install2.r  shinyjs
RUN install2.r  DBI
RUN install2.r  plumber
RUN install2.r  data.table
RUN install2.r  gmailr
RUN install2.r  pander

COPY /shiny-server-1.5.17.0-s390x.deb /tmp/shiny-server-1.5.17.0-s390x.deb

RUN dkpg -i /tmp/shiny-server-1.5.17.0-s390x.deb