FROM docker.io/ashish1981/s390x-ubuntu-r-base

ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2020-04-24}
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
   

# RUN apt-get update && apt-get install -y \
#     default-jdk \
#     default-jre \
#     && unset JAVA_HOME \
#     && sudo R CMD javareconf   

RUN apt-get update && apt-get install -y \
    supervisor \
    git-core \
    libsodium-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    xtail && \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x && \
    export PATH=$JAVA_HOME/bin/:$PATH && \
    setarch s390x R CMD javareconf

## Add a library directory (for user-installed packages)
RUN mkdir -p /usr/local/lib/R/site-library \
    # && chown root:staff /usr/local/lib/R/site-library \
    && chmod g+ws /usr/local/lib/R/site-library \
    ## Fix library path
    && sed -i '/^R_LIBS_USER=.*$/d' /usr/local/lib/R/etc/Renviron \
    && echo "R_LIBS_USER=\${R_LIBS_USER-'/usr/local/lib/R/site-library'}" >> /usr/local/lib/R/etc/Renviron \
    && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
    ## Set configured CRAN mirror
    && if [ -z "$BUILD_DATE" ]; then MRAN=$CRAN; \
    else MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE}; fi \
    && echo MRAN=$MRAN >> /etc/environment \
    && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site \
    ## Use littler installation scripts
    && Rscript -e "install.packages(c('docopt'), dependencies = TRUE, repo = '$CRAN')" \
    # && Rscript -e "install.packages(c('littler'), dependencies = TRUE, repo = '$CRAN')" \
    # # # && Rscript -e "install.packages(c('plumber', 'RJDBC', 'rJava', 'DBI', 'dplyr'), dependencies = TRUE, repo = '$CRAN')" \
    # && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    # && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    # && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
    # Clean up from R source install
    && cd / \
    && rm -rf /tmp/* \
    # && apt-get remove --purge -y $BUILDDEPS \
    # && apt-get autoremove -y \
    # && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages(c('devtools'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('class'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('zoo'), dependencies = TRUE, repo = '$CRAN')"
# 
RUN Rscript -e "install.packages(c('lattice'), dependencies = TRUE, repo = '$CRAN')"
# 
RUN Rscript -e "install.packages(c('littler'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('hexbin'), dependencies = TRUE, repo = '$CRAN')"
# 
RUN Rscript -e "install.packages(c('rJava'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('RJDBC'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('shiny'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('shinydashboard'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('curl'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('httr'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('jsonlite'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('DT'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('shinyalert'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('stringr'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('dplyr'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('plotly'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('rmarkdown'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('leaflet'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('htmlwidgets'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('data.table'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('shinyjs'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('DBI'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('DBI'), dependencies = TRUE, repo = '$CRAN')"
#
RUN Rscript -e "install.packages(c('plumber'), dependencies = TRUE, repo = '$CRAN')"
#
