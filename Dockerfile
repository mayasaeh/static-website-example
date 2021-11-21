FROM nginx

ADD ./static-website /usr/share/nginx/html

EXPOSE 80