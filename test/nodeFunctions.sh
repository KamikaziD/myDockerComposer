#!/bin/bash

. ../scripts/common/functions.sh

create_node_files() {
  echo "Creating Dockerfile..."
  read -p "Please enter your project name: " project_name
  mkdir "${project_name}" && cd "${project_name}" || exit 1
  echo "PORT=5001" >> .env
  echo "init..."
  npm init -y
  echo "npm i ..."
  npm i express dotenv && npm i -D nodemon ts-node concurrently && npm i -D typescript @types/express @types/node && npm i --save-dev tsc-alias && npm i tsconfig-paths --save
#  npm i express dotenv && npm i -D nodemon ts-node concurrently && npm i -D typescript @types/express @types/node
  echo "npm i -D ..."
  npm i -D nodemon ts-node concurrently typescript @types/express @types/node
  echo "TS init ..."
  npx tsc --init
  # Setup nodemon
  echo "Nodemon config ..."
  # shellcheck disable=SC2129
#"exec": "concurrently \"npx tsc --watch\" \"ts-node -r tsconfig-paths/register src/index.ts\""
  dev_cmd=""
  watch_str=' \"npx tsc --watch\"'
  ts_node_str=' \"ts-node -r tsconfig-paths/register src/index.ts\"'
  concur_str='"concurrently'
  exec_str='"exec": '
  dbl_q='"'

  dev_cmd+="${exec_str}"
  dev_cmd+="${concur_str}"
  dev_cmd+="${watch_str}"
  dev_cmd+="${ts_node_str}"
  dev_cmd+="${dbl_q}"


  # shellcheck disable=SC2129
  echo "{" >> nodemon.json
  echo '  "watch": ["src"],' >> nodemon.json
  echo '  "ext": "ts",' >> nodemon.json
  echo "  ${dev_cmd}" >> nodemon.json
  echo "}" >> nodemon.json
  # Update package.json
  echo "Updating packages.json..."

  # Update package.json
#  update_package_json_function 'scripts": {' '  "build": "npx tsc",' "package.json" .
  update_package_json_function 'scripts": {' '  "build": "tsc --project tsconfig.json && tsc-alias -p tsconfig.json",' "package.json" .
  update_package_json_function '"build": "tsc --project tsconfig.json && tsc-alias -p tsconfig.json",' '  "start": "node dist/index.js",' "package.json"
  update_package_json_function '"start": "node dist/index.js",' '  "dev": "nodemon -r tsconfig-paths/register src/index.ts",' "package.json" .

  # Update tsconfig.json
  echo "Updating tsconfig.json..."
  update_package_json_function '"module": "commonjs",' '  "outDir": "./dist",' "tsconfig.json" .

  # Setting up a path alias using ts.config
  update_package_json_function '"module": "commonjs",' '  },' "tsconfig.json" .
  update_package_json_function '"module": "commonjs",' '    "@utils/*": ["./src/utils/*"]' "tsconfig.json" .
  update_package_json_function '"module": "commonjs",' '    "@services/*": ["./src/services/*"],' "tsconfig.json" .
  update_package_json_function '"module": "commonjs",' '  "paths": {' "tsconfig.json" .

  mkdir src && cd src || exit 1
  echo "Creating index.ts..."
  echo
  # shellcheck disable=SC2129
  echo 'import express, { Express, Request, Response } from "express"' >> index.ts
  echo 'import { TestHelperFunction } from "@utils/helpers"' >> index.ts
  echo 'import { TestServiceFunction } from "@services/service"' >> index.ts
  echo 'import dotenv from "dotenv"' >> index.ts
  echo "" >> index.ts
  echo "dotenv.config()" >> index.ts
  echo "" >> index.ts
  echo "const app: Express = express()" >> index.ts
  echo "const port = process.env.PORT || 5001" >> index.ts
  echo "" >> index.ts
  echo 'app.get("/", (req: Request, res: Response) => {' >> index.ts
  echo '  TestHelperFunction()' >> index.ts
  echo '  TestServiceFunction()' >> index.ts
  echo '  res.send("Express + TypeScript Server")' >> index.ts
  echo '})' >> index.ts
  echo "" >> index.ts
  echo 'app.listen(port, () => {' >> index.ts
  # shellcheck disable=SC2016
  echo '  console.log(`[server]: Server is running at http://localhost:${port}`)' >> index.ts
  echo '})' >> index.ts

  echo "Creating Utils..."
  echo
  mkdir utils && cd utils || exit 1
  # shellcheck disable=SC2129
  echo 'export const TestHelperFunction = () => {' >> helpers.ts
  echo '    console.log("Test helper function succeeded!!");' >> helpers.ts
  echo '}' >> helpers.ts
  echo '' >> helpers.ts
  echo 'module.exports = { TestHelperFunction }' >> helpers.ts
  echo "" >> helpers.ts

  cd ..
  echo "Creating Services..."
  echo
  mkdir services && cd services || exit 1
  # shellcheck disable=SC2129
  echo 'export const TestServiceFunction = () => {' >> service.ts
  echo '    console.log("Test service function succeeded!!");' >> service.ts
  echo '}' >> service.ts
  echo '' >> service.ts
  echo 'module.exports = { TestServiceFunction }' >> service.ts
  echo "" >> service.ts

  cd ..
  cd ..
  echo "Creating Docker Files..."
  cat ../Dockerfile >> Dockerfile
  cat ../docker-compose.yaml >> docker-compose.yaml
}

create_node_files
