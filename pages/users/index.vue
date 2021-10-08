<template>
  <div>
    <section class="hero is-bold is-primary">
      <div class="hero-body">
        <div class="container">
          <h1 class="title">
            Users
          </h1>

          <button
            class="button is-primary is-inverted"
            @click="onNewUserOpen"
          >
            <span class="icon">
              <i class="fab fa fa-user-plus"></i>
            </span>
            <span>Add new user</span>
          </button>
        </div>
      </div>
    </section>

    <section class="users">
      <div class="container">
        <table class="table is-fullwidth">
          <thead>
            <tr>
              <th>
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-user-circle-o"></i>
                </span>
              </th>

              <th width="15%">
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-shield"></i>
                </span>
              </th>

              <th
                width="5%"
                class="has-text-centered"
              >
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-square"></i>
                </span>
              </th>

              <th
                width="5%"
                class="has-text-centered"
              >
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-check-square"></i>
                </span>
              </th>

              <th
                width="5%"
                class="has-text-centered"
              >
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-comments"></i>
                </span>
              </th>

              <th width="25%">
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-clock-o"></i>
                </span>
              </th>

              <th width="15%"></th>
            </tr>
          </thead>

          <tbody>
            <tr
              v-for="user in users"
              :key="user.id"
              class="users-item"
            >
              <td>
                {{ user.username }}
              </td>

              <td>
                {{ user.role }}
              </td>

              <td class="has-text-centered">
                {{ user.author_todo_count }}
              </td>

              <td class="has-text-centered">
                {{ user.author_done_count }}
              </td>

              <td class="has-text-centered">
                {{ user.author_todo_comment_count }}
              </td>

              <td>
                {{ user.created_at | dateTime }}
              </td>

              <td>
                <user-action
                  :user="user"
                  @role-switched="reloadCurrentPage"
                  @user-deleted="reloadCurrentPage"
                />
              </td>
            </tr>
          </tbody>
        </table>

        <pager
          v-bind="meta"
          :disabled="loading"
          @turn-page="load"
        />
      </div>
    </section>

    <user-modal-new
      :active.sync="newUserActive"
      @create="gotoFirstPage"
    />
  </div>
</template>

<script>
  import { mapActions } from 'vuex';
  import Pager from '~/components/pager';
  import UserAction from './-components/user-action';
  import UserModalNew from './-components/user-modal-new';

  export default {
    middleware: ['admin'],

    components: {
      Pager,
      UserAction,
      UserModalNew,
    },

    asyncData: async ({ store }) => {
      const { meta, items: users } = await store.dispatch('user/all');
      return { meta, users };
    },

    data: () => ({
      meta: {}, // async
      items: [], // async
      newUserActive: false, // modal toggle
      loading: false,
    }),

    methods: {
      ...mapActions('user', { loadAll: 'all' }),

      onNewUserOpen() {
        this.newUserActive = true;
      },

      reloadCurrentPage() {
        const { limit, offset } = this.meta;
        this.load({ limit, offset });
      },

      gotoFirstPage() {
        this.load({ offset: 0 });
      },

      async load(criteria = {}) {
        this.loading = true;
        const { meta = {}, items = [] } = await this.loadAll(criteria);
        this.loading = false;

        this.meta = meta;
        this.users = items;
      },
    },
  };
</script>
