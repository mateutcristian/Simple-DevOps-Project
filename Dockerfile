# Declaram numele si varianta imaginii
FROM tomcat:latest
# Pentru a putea accesa Tomcat din browser trebuie sa copiem tot contetul din directorul webapps.dist in directorul webapps.
RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
# Copiem artefactele .war din locatia curenta in locatia indicata
COPY ./*.war /usr/local/tomcat/webapps
