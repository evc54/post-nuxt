<template>
  <form
    class="box -login"
    @submit.prevent="onLogin"
  >
    <h1 class="title is-4 spaced -title">Log in</h1>

    <server-error
      :error="error"
      :error-data="errorData"
    />

    <div class="field">
      <label
        for="username"
        class="label"
      >Username</label>

      <div class="control">
        <input
          v-model="username"
          :disabled="loading"
          id="username"
          type="text"
          class="input is-medium"
        />
      </div>
    </div>

    <div class="field">
      <label
        for="password"
        class="label"
      >Password</label>

      <div class="control">
        <input
          v-model="password"
          :disabled="loading"
          id="password"
          type="password"
          class="input is-medium"
        />
      </div>
    </div>

    <div class="field -buttons">
      <div class="control">
        <button
          class="button is-primary is-medium"
          :class="{ 'is-loading': loading }"
        >Connect</button>
      </div>
    </div>
  </form>
</template>

<script>
  import { mapGetters, mapActions } from 'vuex';
  import ServerError from '~/components/server-error';

  export default {
    components: {
      ServerError,
    },

    data: () => ({
      username: 'admin',
      password: 'password',
      loading: false,

      // server error
      error: false,
      errorData: {},
    }),

    computed: {
      ...mapGetters('auth', ['token']),
    },

    methods: {
      ...mapActions('auth', ['login']),
      ...mapActions('user', ['info']),

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.loading = false;
      },

      async onLogin() {
        this.error = false;
        this.loading = true;

        const data = {
          username: this.username,
          password: this.password,
        };

        const login = await this.login(data);
        if (login.status === 'error') return this.onError(login.error);

        const info = await this.info();
        if (info.status === 'error') return this.onError(info.error);

        if (this.token) {
          const Cookie = require('js-cookie');
          Cookie.set('jwt', this.token);
        }

        this.loading = false;
        this.$router.replace('/');
      },
    },
  };
</script>

<style scoped>
  .-login {
    width: 20rem;
    margin: 5rem auto 0;
  }

  .-title {
    padding-bottom: 1rem;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  }

  .-buttons {
    margin-top: 2rem;
  }
</style>
