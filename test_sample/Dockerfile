FROM node:22-bookworm-slim AS base
WORKDIR /app
COPY package*.json ./
ENV PORT=3001
EXPOSE ${PORT}

FROM base AS builder
COPY . .
RUN npm run build


FROM base AS dev
ENV NODE_ENV=development
RUN npm install
COPY . .
CMD npm run dev
