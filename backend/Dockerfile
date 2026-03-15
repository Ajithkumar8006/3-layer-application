FROM node:18-slim
WORKDIR /app
# Install dependencies directly to avoid local path issues
RUN npm install express mongoose cors
COPY . .
EXPOSE 3002
CMD ["node", "index.js"]