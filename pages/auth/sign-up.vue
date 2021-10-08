<template>
  <form
    class="box -sign-up"
    @submit.prevent="onSignUp"
  >
    <h1 class="title is-4 spaced -title">Sign Up</h1>

    <server-error
      :error="error"
      :error-data="errorData"
    />

    <form-username
      v-model="username"
      :disabled="loading"
      ref="username"
      label="Choose user name"
    />

    <form-password
      v-model="password"
      :disabled="loading"
      ref="password"
      label="Enter password"
    />

    <div class="field -buttons">
      <div class="control">
        <button
          class="button is-primary is-medium"
          :class="{ 'is-loading': loading }"
        >Proceed</button>
      </div>
    </div>
  </form>
</template>

<script>
  import { mapGetters, mapActions } from 'vuex';
  import ServerError from '~/components/server-error';
  import FormUsername from '~/components/form-username';
  import FormPassword from '~/components/form-password';

  export default {
    components: {
      ServerError,
      FormUsername,
      FormPassword,
    },

    data: () => ({
      username: '',
      password: '',
      loading: false,

      // server error
      error: false,
      errorData: {},
    }),

    computed: {
      ...mapGetters('auth', ['token']),
    },

    methods: {
      ...mapActions('auth', ['signup', 'login']),
      ...mapActions('user', ['info']),

      isFormValid() {
        return [
          this.$refs.username,
          this.$refs.password,
        ].reduce((c, v) => c || v.validate(), false);
      },

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.loading = false;
      },

      async onSignUp() {
        this.error = false;
        if (!this.isFormValid()) return;

        const data = {
          username: this.username,
          password: this.password,
        };

        this.loading = true;

        const signup = await this.signup(data);
        if (signup.status === 'error') return this.onError(signup.error);

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
  .-sign-up {
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
