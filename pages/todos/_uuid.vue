<template>
  <div>
    <section
      class="hero is-bold"
      :class="{
        'is-success': todo.done,
        'is-primary': !todo.done,
      }"
    >
      <div class="hero-body">
        <div class="container">
          <h1 class="title">
            {{ todo.text }}
          </h1>

          <h2 class="subtitle">
            by <strong>{{ todo.todo_author.username }}</strong>
            at {{ todo.created_at | dateTime }}
          </h2>

          <div
            v-if="isAuthor"
            class="content"
          >
            <button
              :disabled="marking"
              class="button is-inverted"
              :class="{
                'is-loading': marking,
                'is-primary': !todo.done,
                'is-success': todo.done,
              }"
              @click="toggle"
            >
              <span class="icon">
                <i
                  class="fab fa fa-check"
                  :class="{
                    'fa-check': !todo.done,
                    'fa-undo': todo.done,
                  }"
                ></i>
              </span>

              <span>
                {{ todo.done ? 'Do it again' : 'Mark as done' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </section>

    <section
      v-if="comments.length > 0"
      class="section"
    >
      <div class="container">
        <div class="content">
          <h4>What the others think about this</h4>
        </div>

        <comment
          v-for="comment in comments"
          :key="comment.id"
          :comment="comment"
          class="comment"
        />

        <pager
          v-bind="meta"
          :disabled="loading"
          class="pagination"
          @turn-page="load"
        />
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="content">
          <h4>Post your comment</h4>
        </div>

        <form
          class="form"
          @submit.prevent="addComment"
        >
          <article class="media">
            <figure class="media-left">
              <p class="image is-48x48 icon has-text-grey-light">
                <i class="fas fa fa-user-circle fa-3x"></i>
              </p>
            </figure>

            <div class="media-content">
              <div class="field">
                <p class="control">
                  <textarea
                    v-model="text"
                    :disabled="posting"
                    placeholder="Write something here"
                    class="textarea"
                    :class="{ 'is-loading': posting, 'is-danger': !!error }"
                  ></textarea>
                </p>

                <p
                  v-if="!!error"
                  class="help is-danger"
                >{{ error }}</p>
              </div>

              <nav class="level">
                <div class="level-left">
                  <div class="level-item">
                    <button
                      :disabled="posting"
                      type="submit"
                      class="button is-primary"
                      :class="{ 'is-loading': posting }"
                    >Send</button>
                  </div>
                </div>
              </nav>
            </div>
          </article>
        </form>
      </div>
    </section>
  </div>
</template>

<script>
  import { mapGetters, mapActions } from 'vuex';
  import { lastPageCriteria } from "~/helpers/pager";
  import Comment from './-components/comment';
  import Pager from '~/components/pager';

  export default {
    middleware: ['auth'],

    components: {
      Comment,
      Pager,
    },

    asyncData: async ({ store, params }) => {
      const requests = [
        store.dispatch('todo/one', params.uuid),
        store.dispatch('comment/all', { todo_id: `eq.${params.uuid}` }),
      ];

      const [todo, { meta, items: comments }] = await Promise.all(requests);

      return { todo, meta, comments };
    },

    data: () => ({
      todo: {}, // async
      meta: {}, // comments meta, async
      comments: [], // comment items, async

      // mark as done
      marking: false,

      // pager
      loading: false,

      // comment
      text: '',
      error: null,
      posting: false,
    }),

    computed: {
      ...mapGetters('user', {
        userId: 'id',
        username: 'username',
      }),

      isAuthor() {
        return this.userId === this.todo.author_id;
      },
    },

    watch: {
      text() {
        this.error = null;
      },
    },

    methods: {
      ...mapActions('todo', {
        markTodoAs: 'markAs',
      }),

      ...mapActions('comment', {
        loadComments: 'all',
        createComment: 'create',
      }),

      async load(criteria = {}) {
        criteria.todo_id = `eq.${this.todo.id}`;

        this.loading = true;
        const { meta = {}, items = [] } = await this.loadComments(criteria);
        this.loading = false;

        this.meta = meta;
        this.comments = items;
      },

      validateText() {
        if (this.text === '') {
          this.error = 'You have to write something!';
          return false;
        }

        return true;
      },

      async addComment() {
        if (!this.validateText()) return;

        const data = {
          todo_id: this.todo.id,
          author_id: this.userId,
          text: this.text,
        };

        this.posting = true;
        await this.createComment(data);
        this.posting = false;
        this.text = '';

        this.load(lastPageCriteria(this.meta));
      },

      async toggle() {
        const newState = !this.todo.done;

        this.marking = true;
        await this.markTodoAs({ id: this.todo.id, newState });
        this.marking = false;

        this.todo.done = newState;
      },
    },
  };
</script>

<style scoped>
  .section + .section {
    padding-top: 0;
  }

  .comment + .comment {
    border-top: 1px solid hsl(0, 0%, 86%);
  }

  .pagination {
    margin: 1rem 0 2rem;
  }
</style>
