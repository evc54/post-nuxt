<template>
  <div>
    <div class="app">
      <nav
        role="navigation"
        aria-label="main navigation"
        class="navbar"
      >
        <div class="container">
          <div class="navbar-brand">
            <nuxt-link
              to="/"
              class="navbar-item"
            >
              <strong>PostgREST</strong>
            </nuxt-link>

            <a
              role="button"
              aria-label="menu"
              aria-expanded="false"
              data-target="navbar"
              class="navbar-burger burger"
            >
              <span aria-hidden="true"></span>
              <span aria-hidden="true"></span>
              <span aria-hidden="true"></span>
            </a>
          </div>

          <div
            id="navbar"
            class="navbar-menu"
          >
            <div class="navbar-start">
              <nuxt-link
                v-if="isLogged"
                to="/todos"
                class="navbar-item"
              >TODOs</nuxt-link>

              <span
                v-if="isLogged"
                class="navbar-item"
              >
                <nuxt-link
                  to="/todos/new"
                  class="button is-primary"
                >
                  <span class="icon">
                    <i class="fas fa fa-plus"></i>
                  </span>
                  <span>TODO</span>
                </nuxt-link>
              </span>
            </div>

            <div class="navbar-end">
              <nuxt-link
                v-if="isAdministrator"
                to="/users"
                class="navbar-item"
              >Users</nuxt-link>

              <div class="navbar-item">
                <div class="buttons">
                  <nuxt-link
                    v-show="!isLogged"
                    to="/auth/sign-up"
                    class="button is-info"
                  >
                    <strong>Sign up</strong>
                  </nuxt-link>

                  <nuxt-link
                    v-show="!isLogged"
                    to="/auth/login"
                    class="button is-primary"
                  >Log in</nuxt-link>

                  <a
                    v-show="isLogged"
                    class="button is-info"
                    @click="logout"
                  >Log out</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <nuxt/>
    </div>

    <footer class="footer">
      <div class="content has-text-centered">
        <p>
          <a
            href="https://postgrest.org/"
            target="_blank"
          >PostgREST</a>
          and
          <a
            href="https://nuxtjs.org/"
            target="_blank"
          >NUXT.js</a>
        </p>
      </div>
    </footer>
  </div>
</template>

<script>
  import { mapGetters, mapActions, mapMutations } from 'vuex';

  export default {
    computed: {
      ...mapGetters('auth', ['isLogged']),
      ...mapGetters('user', ['isAdministrator', 'isUser']),
    },

    methods: {
      ...mapActions('auth', { authLogout: 'logout' }),
      ...mapMutations('user', { userSet: 'set' }),

      logout() {
        this.authLogout();
        this.userSet();
        this.$router.replace('/');
      },
    },
  };
</script>

<style>
  html,
  body {
    height: 100%;
    min-height: 100%;
    background: #fefefe;
  }
</style>

<style scoped>
  .app {
    padding-bottom: 8rem;
  }

  .navbar {
    padding: 1rem 1.5rem;
    box-shadow: 0 5px 20px -10px rgba(0, 0, 0, 0.15);
  }

  .footer {
    padding: 3rem 1.5rem;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    top: auto;
  }
</style>
