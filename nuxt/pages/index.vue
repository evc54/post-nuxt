<template>
  <div>
    <section
      class="hero is-bold"
      :class="{
        'is-success': isLogged,
        'is-warning': !isLogged
      }"
    >
      <div class="hero-body">
        <div class="container">
          <h1 class="title">
            Hello, {{ name }}!
          </h1>

          <h2 class="subtitle">
            <span v-if="isLogged && active.length">
              There is something you have not done yet.
            </span>

            <span v-if="isLogged && !active.length">
              Nice work! Now take a rest.
            </span>

            <span v-if="!isLogged">
              To continue using this app you can
              <nuxt-link
                to="/auth/sign-up"
                class="button is-small is-info"
              >sign up</nuxt-link>
              or
              <nuxt-link
                to="/auth/login"
                class="button is-small is-primary"
              >log in</nuxt-link>
            </span>
          </h2>
        </div>
      </div>
    </section>

    <section
      v-if="isLogged"
      class="todo-items"
    >
      <div class="container">
        <table class="table is-hoverable is-fullwidth">
          <thead>
            <tr>
              <th
                width="1%"
                class="has-text-centered"
              >
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-check"></i>
                </span>
              </th>

              <th>
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-align-left"></i>
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
            </tr>
          </thead>

          <tbody>
            <tr
              v-if="active.length > 0"
              v-for="item in active"
              :key="item.id"
              class="todo-item"
              @click="$router.push(`/todos/${item.id}`)"
            >
              <td>
                <span
                  class="icon"
                  :class="{
                    'has-text-primary': item.done,
                    'has-text-grey-light': !item.done,
                  }"
                >
                  <i
                    class="fas fa fa-lg"
                    :class="{
                      'fa-check-square': item.done,
                      'fa-square': !item.done,
                    }"
                  ></i>
                </span>
              </td>

              <td>
                {{ item.text }}
              </td>

              <td class="has-text-centered">
                {{ item.todo_comment_count }}
              </td>

              <td>
                {{ item.created_at | dateTime }}
              </td>
            </tr>

            <tr v-if="active.length === 0">
              <td colspan="4">
                Everything is done! Congratulations!
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  asyncData: async ({ store }) => {
    if (!store.getters['auth/isLogged']) return {};

    const { items: active = [] } = await store.dispatch('todo/all', {
      author_id: `eq.${store.getters['user/id']}`,
      done: 'is.false',
      select: '*,todo_comment_count',
      order: 'created_at.desc',
      limit: 50,
    });

    return { active };
  },

  data: () => ({
    active: [], // async
  }),

  computed: {
    ...mapGetters('auth', ['isLogged']),
    ...mapGetters('user', ['username']),

    name() {
      return this.isLogged ? this.username : 'anonymous user';
    },
  },
};
</script>

<style scoped>
  .todo-items {
    margin-top: 1.5rem;
  }

  .todo-item {
    cursor: pointer;
  }
</style>
