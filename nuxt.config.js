module.exports = {
  debug: true,

  head: {
    title: 'Nuxt/PostgREST',

    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: 'Nuxt.js meets PostgREST' },
    ],

    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      {
        rel: 'stylesheet',
        href: 'https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.4/css/bulma.min.css',
      },
      {
        rel: 'stylesheet',
        href:
          'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css',
      },
    ],
  },

  loading: { color: '#3B8070' },

  modules: ['@nuxtjs/axios'],

  axios: {
    baseURL: 'http://127.0.0.1:3001',
    proxyHeaders: false,
  },

  plugins: [
    { src: '~/plugins/client.js', ssr: false },
    '~/plugins/directives.js',
    '~/plugins/filters.js',
    '~/plugins/axios.js',
  ],

  build: {
    extend(config, { isDev, isClient }) {
      if (isDev && isClient) {
        config.devtool = 'eval-source-map';
        config.module.rules.push({
          enforce: 'pre',
          test: /\.(js|vue)$/,
          loader: 'eslint-loader',
          exclude: /(node_modules)/,
        });
      }
    },
  },
};
