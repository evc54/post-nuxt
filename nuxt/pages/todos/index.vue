<template>
  <div>
    <section class="hero is-bold is-info">
      <div class="hero-body">
        <div class="container">
          <h1 class="title">
            To Do List
          </h1>

          <h2 class="subtitle">
            Everybody has something to be done.
          </h2>

          <button
            :disabled="loading"
            class="button is-success is-inverted"
            :class="{ 'is-loading': loading }"
            @click="toggleCompleted"
          >
            <span class="icon is-success">
              <i
                class="fab fa"
                :class="{
                  'fa-check': !completed,
                  'fa-times': completed,
                }"
              ></i>
            </span>
            <span v-if="completed">Exclude completed</span>
            <span v-else>Include completed</span>
          </button>
        </div>
      </div>
    </section>

    <section class="todo-items">
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

              <th width="15%">
                <span class="icon is-small has-text-grey-light">
                  <i class="fas fa fa-user-circle-o"></i>
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
              v-if="items.length > 0"
              v-for="item in items"
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
                {{ item.todo_author.username }}

                <div class="content is-small has-text-grey">
                  {{ item.todo_author.role }}
                </div>
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

            <tr v-if="items.length === 0">
              <td colspan="4">
                Everything is done! Congratulations!
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
  </div>
</template>

<script>
  import { mapActions } from 'vuex';
  import Pager from '~/components/pager';

  export default {
    middleware: [ 'auth' ],

    components: {
      Pager,
    },

    asyncData: async ({ store }) => {
      const { meta, items } = await store.dispatch('todo/all', { done: 'is.false' });
      return { meta, items };
    },

    data: () => ({
      meta: {}, // async
      items: [], // async
      completed: false,
      loading: false,
    }),

    methods: {
      ...mapActions('todo', { loadAll: 'all' }),

      async load(criteria = {}) {
        if (!this.completed) {
          criteria.done = 'is.false';
        }

        this.loading = true;
        const { meta = {}, items = [] } = await this.loadAll(criteria);
        this.loading = false;

        this.meta = meta;
        this.items = items;
      },

      async toggleCompleted() {
        this.completed = !this.completed;
        this.load();
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
