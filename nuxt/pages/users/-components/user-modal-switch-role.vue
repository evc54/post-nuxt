<template>
  <form
    class="modal"
    :class="{ 'is-active': active }"
    @submit.prevent="onSwitch"
  >
    <div class="modal-background"></div>

    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Switch User Role</p>

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
          <label class="label">Current role</label>

          <div class="control">
            <div
              disabled="true"
              class="input is-medium"
            >{{ user.role }}</div>
          </div>
        </div>

        <div class="field">
          <label class="label">New role</label>

          <div class="control">
            <div
              disabled="true"
              class="input is-medium"
            >{{ role }}</div>
          </div>
        </div>
      </section>

      <footer class="modal-card-foot">
        <button
          :disabled="switching"
          type="submit"
          class="button is-primary"
          :class="{ 'is-loading': switching }"
        >Switch</button>

        <button
          :disabled="switching"
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

  export default {
    components: {
      ServerError,
    },

    props: {
      active: { type: Boolean, default: false },
      user: { type: Object, required: true },
      role: { type: String },
    },

    data: () => ({
      switching: false,

      // server error
      error: false,
      errorData: {},
    }),

    methods: {
      ...mapActions('user', { switchRole: 'switch' }),

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.switching = false;
      },

      async onSwitch() {
        if (this.switching) return;

        const data = {
          id: this.user.id,
          role: this.role,
        };

        this.switching = true;
        const role = await this.switchRole(data);
        if (role.status === 'error') return this.onError(role.error);

        this.switching = false;
        this.$emit('success');
        this.onClose();
      },

      onClose() {
        this.$emit('update:active', false);
      },
    },
  };
</script>

<style scoped>
  .modal-card {
    max-width: 25rem;
  }
</style>
