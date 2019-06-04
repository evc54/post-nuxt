<template>
  <form
    class="modal"
    :class="{ 'is-active': active }"
    @submit.prevent="onCreate"
  >
    <div class="modal-background"></div>

    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">New User</p>

        <button
          type="button"
          aria-label="close"
          class="delete"
          @click="onClose"
        ></button>
      </header>

      <section class="modal-card-body">
        <server-error
          :error="error"
          :error-data="errorData"
        />

        <form-username
          v-model="username"
          ref="username"
          :disabled="adding"
        />

        <form-password
          v-model="password"
          ref="password"
          :disabled="adding"
        />

        <div class="field">
          <label
            for="role"
            class="label"
          >Role</label>

          <div class="control has-icons-left">
            <div class="select is-medium">
              <select
                v-model="role"
                id="role"
              >
                <option
                  v-for="(role, index) in roles"
                  :key="index"
                  :value="role"
                >{{ role }}</option>
              </select>
            </div>

            <span class="icon is-left">
              <i class="fas fa fa-shield"></i>
            </span>
          </div>
        </div>
      </section>

      <footer class="modal-card-foot">
        <button
          :disabled="adding"
          type="submit"
          class="button is-primary"
          :class="{ 'is-loading': adding }"
        >Create</button>

        <button
          :disabled="adding"
          type="button"
          class="button"
          @click="onClose"
        >Cancel</button>
      </footer>
    </div>
  </form>
</template>

<script>
  import { mapActions } from 'vuex';
  import ServerError from '~/components/server-error';
  import FormUsername from '~/components/form-username';
  import FormPassword from '~/components/form-password';
  import { ROLE_USER, ROLE_ADMINISTRATOR } from "~/store/user/const";

  export default {
    components: {
      ServerError,
      FormUsername,
      FormPassword,
    },

    props: {
      active: { type: Boolean, default: false },
    },

    watch: {
      active() {
        this.resetForm();
        this.resetFormValidators();
      },
    },

    data: () => ({
      username: '',
      password: '',
      role: ROLE_USER,
      adding: false,

      // server error
      error: false,
      errorData: {},
    }),

    computed: {
      roles() {
        return [ ROLE_USER, ROLE_ADMINISTRATOR ];
      },
    },

    methods: {
      ...mapActions('user', ['create']),

      isFormValid() {
        return [
          this.$refs.username,
          this.$refs.password,
        ].reduce((c, v) => c || v.validate(), false);
      },

      resetFormValidators() {
        return [
          this.$refs.username,
          this.$refs.password,
        ].forEach(v => v.resetValidation());
      },

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.loading = false;
      },

      async onCreate() {
        if (this.adding) return;
        if (!this.isFormValid()) return;

        const data = {
          username: this.username,
          password: this.password,
          role: this.role,
        };

        const user = await this.create(data);
        if (user.status === 'error') return this.onError(user.error);

        this.$emit('create', user);
        this.onClose();
      },

      onClose() {
        this.$emit('update:active', false);
      },

      resetForm() {
        this.username = '';
        this.password = '';
        this.role = ROLE_USER;
      },
    },
  };
</script>

<style scoped>
  .modal-card {
    max-width: 25rem;
  }

  .select,
  .select select {
    width: 100%;
  }
</style>
