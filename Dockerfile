FROM docker.io/ashish1981/s390x-ubuntu-r-base

ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2020-04-24}
ENV R_VERSION=${R_VERSION:-3.6.3} \
    CRAN=${CRAN:-https://cran.rstudio.com} \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl4 \
    # libicu63 \
    # libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && BUILDDEPS="curl \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.6-dev \
    tk8.6-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
    && apt-get install -y --no-install-recommends $BUILDDEPS


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
    && Rscript -e "install.packages(c('docopt'), repo = '$CRAN')" \
    # && Rscript -e "install.packages(c('littler', 'docopt'), repo = '$CRAN')" \
    # # && Rscript -e "install.packages(c('plumber', 'RJDBC', 'rJava', 'DBI', 'dplyr'), repo = '$CRAN')" \
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
RUN Rscript -e "install.packages(c('rJava'), repo = '$CRAN')"
RUN Rscript -e "install.packages(c('plumber'), repo = '$CRAN')"
RUN Rscript -e "install.packages(c('RJDBC'), repo = '$CRAN')"
RUN Rscript -e "install.packages(c('DBI',), repo = '$CRAN')"
RUN Rscript -e "install.packages(c('dplyr'), repo = '$CRAN')"
RUN Rscript -e "install.packages(c('shiny'), repo = '$CRAN')"
#CMD ["R"]

# RUN install2.r plumber
# RUN install2.r RJDBC
# RUN install2.r rJava
# RUN install2.r DBI
# RUN install2.r dplyr
