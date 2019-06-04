<template>
  <section class="hero is-medium is-danger is-bold">
    <div class="hero-body">
      <div class="container">
        <h1 class="title">
          {{ statusCode }}
        </h1>

        <h2 class="subtitle">
          {{ message }}
        </h2>

        <p></p>

        <nuxt-link
          to="/"
          class="button is-white"
        >Back to Home page</nuxt-link>
      </div>
    </div>
  </section>
</template>

<script>
  export default {
    props: ['error'],

    computed: {
      errorData() {
        return this.error.response && this.error.response.data;
      },

      statusCode() {
        if (this.errorData) {
          return this.errorData.code;
        }

        if (this.error.statusCode) {
          return this.error.statusCode;
        }

        return 404;
      },

      message() {
        if (this.errorData) {
          return this.errorData.message;
        }

        if (this.error.message) {
          return this.error.message;
        }

        return 'Page not found';
      },
    },
  };
</script>
