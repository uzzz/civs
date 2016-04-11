FROM ubuntu:trusty

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends build-essential apache2 openssl \
                                                  libhtml-tagfilter-perl

COPY . /civs
WORKDIR /civs

# install CIVS
RUN mkdir -p /civs-public/html \
    && mkdir -p /civs-public/cgi-bin
RUN ./install-civs /civs/config/my-config
RUN chown -R www-data:www-data /civs-data

# setup apache
RUN rm /etc/apache2/sites-enabled/* \
    && rm /etc/apache2/sites-available/* \
    && cp civs.apache.conf /etc/apache2/sites-available/civs.conf \
    && ln -s /etc/apache2/sites-available/civs.conf /etc/apache2/sites-enabled/civs.conf
RUN ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/ \
    && ln -s /etc/apache2/mods-available/cgid.conf /etc/apache2/mods-enabled/

RUN mkdir /var/lock/apache2 && \
    mkdir /var/run/apache2


ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/apache2", "-DFOREGROUND" ]
