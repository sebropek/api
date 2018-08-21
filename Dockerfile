FROM centos:7
ENV http_proxy 10.0.2.2:23456
ENV https_proxy 10.0.2.2:23456
RUN yum install epel-release -y
RUN yum update -y 
RUN yum install -y python2-flask-restful.noarch python2-flask-sqlalchemy.noarch python2-pip.noarch MySQL-python.x86_64 
CMD mkdir /opt/app
COPY api.py /opt/app/
CMD [ "python", "/opt/app/api.py" ]
EXPOSE 80/tcp
