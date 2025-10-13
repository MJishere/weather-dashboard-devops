#Base Image
FROM node

#Setting work directory inside the container
WORKDIR /app

#copy package files
COPY package*.json ./

#Install production dependencies only
RUN npm ci --only=production

#Copy the remaining files from local path to the working directory
COPY . .

#Expose 5000 port required by the server
EXPOSE 5000

#Run server.js 
CMD [ "node","server.js"]
