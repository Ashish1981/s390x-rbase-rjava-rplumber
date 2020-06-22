FROM docker.io/ashish1981/s390x-ubuntu-r-base

RUN apt-get update -qq && apt-get install -y \
    git-core \
    libssl-dev \
    libcurl4-gnutls-dev

RUN R -e 'install.packages(c("devtools"))'
RUN R -e 'install.packages(c("plumber"))'
RUN R -e 'install.packages(c("RJDBC"))'
RUN R -e 'install.packages(c("rJava"))'
RUN R -e 'install.packages(c("DBI"))'
RUN R -e 'install.packages(c("dplyr"))'
RUN R -e 'updateR() '


RUN echo "sessionInfo()" | R --save

CMD [ "R" ]

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
CMD ["/usr/local/lib/R/site-library/plumber/examples/04-mean-sum/plumber.R"]