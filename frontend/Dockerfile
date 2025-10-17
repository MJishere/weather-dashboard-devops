# Stage 1: Build

FROM node:latest AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

# Add build ARG for backend URL
ARG VITE_API_URL=/api
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# Stage 2: Serve

FROM nginx

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]