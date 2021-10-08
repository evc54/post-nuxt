# Nuxt.js meets PostgREST

This is advanced TODO application to demonstrate how [Nuxt.js](https://nuxtjs.org) can be integrated with [PostgREST](https://postgrest.org).

## Nuxt.js

Nuxt is open source framework for [Vue.js](https://vuejs.org) based applications supports server side rendering.

## PostgREST

PostgREST is a standalone web server that turns your PostgreSQL database directly into a RESTful API.

## Advanced TODO

Advanced TODO application implements the following modules:
- User's signing up, authentication, role management
- To do task CRUD
- To do task's comment CRUD

The application also uses [bulma](https://bulma.io/) CSS framework.

# How to get up and running

## With Docker

You'll need `git`, `Docker`, `Node.js` and `yarn` installed on your machine.

Make sure no application is using `3000` and `3001` TCP ports.

```bash
git clone https://github.com/evc54/post-nuxt app
cd app
docker-compose up -d # this will build docker image and run it in a background
yarn install # this install dependent node modules
yarn dev # this executes Nuxt.js application in dev mode
```

Now you're ready to open `http://127.0.0.1:3000/` in your favorite browser.

## Standalone deployment

Look at `standalone` directory for example of configuration files.

## License

Entire codebase in this repository is licensed under MIT.
