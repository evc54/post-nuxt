<template>
  <div>
    <section class="hero is-bold is-success">
      <div class="hero-body">
        <div class="container">
          <h1 class="title">
            New To Do
          </h1>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <form
          class="form"
          @submit.prevent="create"
        >
          <div class="field">
            <div class="control">
              <input
                v-model="text"
                class="input"
                type="text"
                placeholder="Type in your needs"
              />
            </div>

            <p
              v-if="!!error"
              class="help is-danger"
            >{{ error }}</p>
          </div>

          <div class="control">
            <button class="button is-primary">Create TODO</button>
          </div>
        </form>
      </div>
    </section>
  </div>
</template>

<script>
  import { mapGetters, mapActions } from 'vuex';

  export default {
    middleware: ['auth'],

    data: () => ({
      text: '',
      error: false,
      adding: false,
    }),

    watch: {
      text() {
        this.error = null;
      },
    },

    computed: {
      ...mapGetters('user', {
        userId: 'id',
      }),
    },

    methods: {
      ...mapActions('todo', {
        createTodo: 'create',
      }),

      validateText() {
        if (this.text === '') {
          this.error = 'You have to write something!';
          return false;
        }

        return true;
      },

      async create() {
        if (!this.validateText()) return;

        const data = {
          text: this.text,
          author_id: this.userId,
        };

        this.adding = true;
        const response = await this.createTodo(data);
        this.adding = false;

        const { id } = response;
        this.$router.push(`/todos/${id}`);
      },
    },
  };
</script>
