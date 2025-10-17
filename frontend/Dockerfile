# Stage 1: Build

FROM node:latest AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

# Add build ARG for backend URL
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# Stage 2: Serve

FROM nginx

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]