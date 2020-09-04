FROM busybox:ubuntu
#FROM gcr.io/google-samples/gb-frontend:v4

ADD ./guestbook /app/guestbook
ADD ./public/ /app/public/

WORKDIR /app
CMD ["./guestbook"]
EXPOSE 3000
