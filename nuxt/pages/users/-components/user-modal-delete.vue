<template>
  <div
    class="modal"
    :class="{ 'is-active': active }"
  >
    <div class="modal-background"></div>

    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Delete User</p>

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
      </section>

      <footer class="modal-card-foot">
        <button
          :disabled="deleting"
          type="button"
          class="button is-danger"
          :class="{ 'is-loading': deleting }"
          @click="onDelete"
        >Delete</button>

        <button
          :disabled="deleting"
          type="button"
          class="button"
          @click="onClose"
        >Cancel</button>
      </footer>
    </div>
  </div>
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
    },

    data: () => ({
      deleting: false,

      // server error
      error: false,
      errorData: {},
    }),

    methods: {
      ...mapActions('user', { deleteUser: 'delete' }),

      onError(err) {
        this.errorData = err;
        this.error = true;
        this.deleting = false;
      },

      async onDelete() {
        if (this.deleting) return;

        this.deleting = true;
        const del = await this.deleteUser(this.user.id);
        if (del.status === 'error') return this.onError(del.error);

        this.deleting = false;
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
