#Base Image
FROM node

# Accept the openweather api key from the jenkins
ARG OPENWEATHER_API_KEY

# Set the api key as env variable
ENV OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY

#Setting work directory inside the container
WORKDIR /app

#copy package files
COPY package*.json ./

#Install production dependencies only
RUN npm ci --only=production

#Copy the remaining files from local path to the working directory
COPY . .

# Default port for app
ENV PORT=5000

#Expose 5000 port required by the server
EXPOSE 5000

#Run server.js 
CMD [ "node","server.js"]
