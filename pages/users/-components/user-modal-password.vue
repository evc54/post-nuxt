<template>
  <form
    class="modal"
    :class="{ 'is-active': active }"
    @submit.prevent="onUpdate"
  >
    <div class="modal-background"></div>

    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Update User Password</p>

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

        <div class="field">
          <label class="label">Username</label>

          <div class="control">
            <div
              disabled="true"
              class="input is-medium"
            >{{ user.username }}</div>
          </div>
        </div>

        <div class="field">
          <label class="label">Role</label>

          <div class="control">
            <div
              disabled="true"
              class="input is-medium"
            >{{ user.role }}</div>
          </div>
        </div>

        <form-password
          v-model="password"
          ref="password"
          :disabled="updating"
          label="New password"
        />
      </section>

      <footer class="modal-card-foot">
        <button
          :disabled="updating"
          type="submit"
          class="button is-primary"
          :class="{ 'is-loading': updating }"
        >Update</button>

        <button
          :disabled="updating"
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
  import FormPassword from '~/components/form-password';

  export default {
    components: {
      ServerError,
      FormPassword,
    },

    props: {
      active: { type: Boolean, default: false },
      user: { type: Object, required: true },
    },

    watch: {
      active() {
        this.resetForm();
        this.resetFormValidators();
      },
    },

    data: () => ({
      password: '',
      updating: false,

      // server error
      error: false,
      errorData: {},
    }),

    methods: {
      ...mapActions('user', { changePassword: 'password' }),

      isFormValid() {
        return this.$refs.password.validate();
      },

      resetFormValidators() {
        this.$refs.password.resetValidation();
      },

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.updating = false;
      },

      async onUpdate() {
        if (this.updating) return;
        if (!this.isFormValid()) return;

        const data = {
          id: this.user.id,
          password: this.password,
        };

        this.updating = true;
        const password = await this.changePassword(data);
        if (password.status === 'error') return this.onError(password.error);

        this.updating = false;
        this.onClose();
      },

      onClose() {
        this.$emit('update:active', false);
      },

      resetForm() {
        this.password = '';
      },
    },
  };
</script>

<style scoped>
  .modal-card {
    max-width: 25rem;
  }
</style>
