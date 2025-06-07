FROM nginx:alpine

# Copy static website files
COPY ./static-content/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]