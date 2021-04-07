FROM debian:buster

LABEL org.label-schema.license="GPL-2.0" \
    org.label-schema.vcs-url="https://github.com/rocker-org/rocker-versioned" \
    org.label-schema.vendor="Rocker Project" \
    maintainer="Carl Boettiger <cboettig@ropensci.org>"

ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2020-04-24}
ENV R_VERSION=${R_VERSION:-3.6.3} \
    CRAN=${CRAN:-https://cran.rstudio.com} \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm
ENV LD_LIBRARY_PATH=/usr/lib/jvm/default-java/lib/server:/usr/lib/jvm/default-java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x

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
    libicu63 \
    libjpeg62-turbo \
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
    default-jdk \
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
    && apt-get install -y --no-install-recommends $BUILDDEPS \
    && cd tmp/ \
    ## Download source code
    && curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz \
    ## Extract source code
    && tar -xf R-${R_VERSION}.tar.gz \
    && cd R-${R_VERSION} \
    ## Set compiler flags
    && R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/perl \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" \
    ## Configure options
    ./configure --enable-R-shlib \
    --enable-memory-profiling \
    --with-readline \
    --with-blas \
    --with-tcltk \
    --disable-nls \
    --with-recommended-packages \
    ## Build and install
    && make \
    && make install \
    ## Add a library directory (for user-installed packages)
    && mkdir -p /usr/local/lib/R/site-library \
    && chown root:staff /usr/local/lib/R/site-library \
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
    && Rscript -e "install.packages(c('littler', 'docopt','shiny'), repo = '$CRAN')" \
    && ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
    ## Clean up from R source install
    && cd / \
    && rm -rf /tmp/* \
    && apt-get remove --purge -y $BUILDDEPS \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

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

COPY /shiny-server-1.5.17.0-s390x.deb /tmp/shiny-server-1.5.17.0-s390x.deb
RUN dpkg -i /tmp/shiny-server-1.5.17.0-s390x.deb

# RUN install2.r  shiny
RUN install2.r --error  rmarkdown
RUN install2.r --error  shinydashboard
RUN install2.r --error  rJava
RUN install2.r --error  RJDBC
RUN install2.r --error  curl
RUN install2.r --error  httr
RUN install2.r --error  jsonlite
RUN install2.r --error  DT
RUN install2.r --error  shinyalert
RUN install2.r --error  stringr
RUN install2.r --error  dplyr
RUN install2.r --error  plotly
RUN install2.r --error  leaflet
RUN install2.r --error  htmlwidgets
RUN install2.r --error  data.table
RUN install2.r --error  shinyjs
RUN install2.r --error  DBI
RUN install2.r --error  plumber
RUN install2.r --error  data.table
RUN install2.r --error  gmailr
RUN install2.r --error  pander

RUN rm -rf /tmp/* \
    && apt-get autoremove -y \
    && apt-get autoclean -y 