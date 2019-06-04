<template>
  <div class="user-action">
    <div class="user-action__actions">

      <a
        title="Change password"
        class="-password"
        @click="onChangePassword"
      >
        <span class="icon">
          <i class="fas fa fa-lock"></i>
        </span>
      </a>

      <a
        v-if="isUser"
        title="Promote to Administrator"
        class="-promote"
        @click="onSwitchRole(ROLE_ADMINISTRATOR)"
      >
        <span class="icon">
          <i class="fas fa fa-thumbs-o-up"></i>
        </span>
      </a>

      <a
        v-if="!isSelf && isAdministrator"
        title="Disgrace to User"
        class="-disgrace"
        @click="onSwitchRole(ROLE_USER)"
      >
        <span class="icon">
          <i class="fas fa fa-thumbs-o-down"></i>
        </span>
      </a>

      <a
        v-if="!isSelf"
        title="Delete"
        class="-delete"
        @click="onDeleteUser"
      >
        <span class="icon">
          <i class="fas fa fa-trash"></i>
        </span>
      </a>
    </div>

    <div class="user-action__modals">
      <user-modal-password
        :active.sync="passwordActive"
        :user="user"
      />

      <user-modal-switch-role
        :active.sync="switchRoleActive"
        :user="user"
        :role="switchRole"
        @success="$emit('role-switched')"
      />

      <user-modal-delete
        :active.sync="deleteActive"
        :user="user"
        @success="$emit('user-deleted')"
      />
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex';
  import { ROLE_USER, ROLE_ADMINISTRATOR } from "~/store/user/const";
  import UserModalPassword from './user-modal-password';
  import UserModalSwitchRole from './user-modal-switch-role';
  import UserModalDelete from './user-modal-delete';

  export default {
    components: {
      UserModalPassword,
      UserModalSwitchRole,
      UserModalDelete,
    },

    props: {
      user: { type: Object, required: true },
    },

    data: () => ({
      passwordActive: false, // modal toggle
      running: false,

      // role switching
      switchRoleActive: false, // modal toggle
      switchRole: null,
      // available roles
      ROLE_USER,
      ROLE_ADMINISTRATOR,

      // delete user
      deleteActive: false, // modal toggle
    }),

    computed: {
      ...mapGetters('user', { userId: 'id' }),

      isSelf() {
        return this.userId === this.user.id;
      },

      isAdministrator() {
        return this.user.role === ROLE_ADMINISTRATOR;
      },

      isUser() {
        return this.user.role === ROLE_USER;
      },
    },

    methods: {
      onChangePassword() {
        this.passwordActive = true;
      },

      onSwitchRole(role) {
        this.switchRole = role;
        this.switchRoleActive = true;
      },

      onDeleteUser() {
        this.deleteActive = true;
      },
    },
  };
</script>

<style scoped>
  .user-action__actions {
    white-space: nowrap;
    text-align: right;
  }

  .user-action__actions a {
    color: hsl(0, 0%, 48%);
  }

  .-password:hover {
    color: hsl(171, 100%, 41%);
  }

  .-promote:hover {
    color: hsl(141, 71%, 48%);
  }

  .-disgrace:hover {
    color: hsl(48, 100%, 67%);
  }

  .-delete:hover {
    color: hsl(348, 100%, 61%);
  }
</style>
