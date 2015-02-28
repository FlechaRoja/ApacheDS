FROM debian:wheezy

MAINTAINER Henrik Sachse <t3x7m3@posteo.de>

#############################################
# ApacheDS installation
#############################################

ENV APACHEDS_VERSION 2.0.0-M19
ENV APACHEDS_ARCH amd64

ENV APACHEDS_ARCHIVE apacheds-${APACHEDS_VERSION}-${APACHEDS_ARCH}.deb
ENV APACHEDS_DATA /var/lib/apacheds-${APACHEDS_VERSION}
ENV APACHEDS_USER apacheds
ENV APACHEDS_GROUP apacheds

VOLUME ${APACHEDS_DATA}

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y curl procps openjdk-7-jre-headless \
    && curl --silent -o ${APACHEDS_ARCHIVE}  http://mirror.softaculous.com/apache/directory/apacheds/dist/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE} \
    && dpkg -i ${APACHEDS_ARCHIVE}

# Ports defined by the default instance configuration:
# 10389: ldap
# 10636: ldaps
# 60088: kerberos
# 60464: changePasswordServer
# 8080: http
# 8443: https
EXPOSE 10389 10636 60088 60464 8080 8443

#############################################
# ApacheDS bootstrap configuration
#############################################

ENV APACHEDS_INSTANCE default
ENV APACHEDS_BOOTSTRAP /bootstrap

ENV APACHEDS_SCRIPT run.sh
ADD scripts/${APACHEDS_SCRIPT} /${APACHEDS_SCRIPT}
RUN chown ${APACHEDS_USER}:${APACHEDS_GROUP} /${APACHEDS_SCRIPT} \
    && chmod u+rx /${APACHEDS_SCRIPT}

ADD instance/* ${APACHEDS_BOOTSTRAP}/conf/
RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions \
    && chown -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_BOOTSTRAP}

#############################################
# ApacheDS wrapper command
#############################################

CMD /${APACHEDS_SCRIPT}
