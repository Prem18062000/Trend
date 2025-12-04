# Dockerfile
FROM nginx:alpine

# Clean default nginx html
RUN rm -rf /usr/share/nginx/html/*

# Copy built frontend to nginx web root
COPY dist /usr/share/nginx/html

# Nginx listens on 80 inside container
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
