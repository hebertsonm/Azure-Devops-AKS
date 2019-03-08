from node:8-jessie

WORKDIR /usr/src/app

COPY appjs/ .

RUN npm install --prod

EXPOSE 8080
CMD [ "npm", "start" ]
