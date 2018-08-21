FROM centos:7
ENV http_proxy 10.0.2.2:23456
ENV https_proxy 10.0.2.2:23456
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASS
ARG DB_NAME
RUN yum install epel-release -y
RUN yum update -y 
RUN yum install -y python2-flask-restful.noarch python2-flask-sqlalchemy.noarch python2-pip.noarch MySQL-python.x86_64 
CMD mkdir /opt/app
COPY api.py /opt/app/
RUN sed -i "s/DB_HOST/$DB_HOST/" /opt/app/api.py
RUN sed -i "s/DB_PORT/$DB_PORT/" /opt/app/api.py 
RUN sed -i "s/DB_USER/$DB_USER/" /opt/app/api.py
RUN sed -i "s/DB_PASS/$DB_PASS/" /opt/app/api.py
RUN sed -i "s/DB_NAME/$DB_NAME/" /opt/app/api.py
CMD [ "python", "/opt/app/api.py" ]
EXPOSE 8080/tcp
