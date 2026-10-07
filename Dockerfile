# Jenkins is using this file to Build Docker Images containing our main Node.js Application (app\server.js in this case) and its dependicies (package.json node etc)

# jenkins then pushes the Image docker hub   

FROM node:20-alpine
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev
COPY app/ .
ENV PORT=3000
EXPOSE 3000
USER node
CMD ["node", "server.js"]