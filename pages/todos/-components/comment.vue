<template>
  <article
    class="media"
    :class="{ '-deleted': isDeleted }"
  >
    <figure class="media-left">
      <p class="image is-48x48 icon has-text-grey-light">
        <i class="fas fa fa-user-circle fa-3x"></i>
      </p>
    </figure>

    <div class="media-content">
      <div class="content">
        <p>
          <strong>{{ comment.todo_comment_author.username }}</strong>
        </p>

        <p class="comment-text">{{ comment.text }}</p>

        <p class="has-text-grey">
          <small>{{ comment.created_at | dateTime }}</small>
        </p>
      </div>
    </div>

    <div
      v-if="isDeleteAllowed"
      class="media-right"
    >
      <button
        class="button is-small is-light"
        :class="{ 'is-loading': deleting }"
        :disabled="deleting || isDeleted"
        @click="deleteComment"
      >
        <span class="icon is-small">
          <i class="fab fa fa-trash"></i>
        </span>
        <span>Delete</span>
      </button>
    </div>

    <div
      v-if="isDeleted"
      class="deleted-banner"
    >
      <i class="fas fa fa-ban"></i>
    </div>
  </article>
</template>

<script>
  import { mapGetters, mapActions } from 'vuex';

  export default {
    props: {
      comment: Object,
    },

    data: () => ({
      deleting: false,
      isDeleted: false,
    }),

    computed: {
      ...mapGetters('user', { userId: 'id' }),

      isDeleteAllowed() {
        return this.userId === this.comment.author_id;
      },
    },

    methods: {
      ...mapActions('comment', { delComment: 'delete' }),

      async deleteComment() {
        this.deleting = true;
        const response = await this.delComment(this.comment.id);
        this.deleting = false;

        if (response.result === 'error') {
          return;
        }

        this.isDeleted = true;
      },
    },
  };
</script>

<style scoped>
  .comment-text {
    font-size: 105%;
    padding: 0;
    line-height: 1.5;
    background: transparent;
    white-space: pre;
  }

  .-deleted {
    position: relative;
  }

  .deleted-banner {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background: rgba(255, 255, 255, 0.85);
  }

  .deleted-banner i {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translateX(-50%) translateY(-50%);
    font-size: 4rem;
    width: 4rem;
    height: 4rem;
    color: rgba(0, 0, 0, 0.15);
  }
</style>
