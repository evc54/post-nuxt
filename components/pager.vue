<template>
  <nav
    v-show="isVisible"
    role="navigation"
    aria-label="pagination"
    class="pagination"
  >
    <a
      :disabled="disabled || !previousPageActive"
      class="pagination-previous is-danger"
      @click="goToPreviousPage"
    >
      <span class="icon">
        <i class="fab fa fa-angle-double-left"></i>
      </span>
      <span>Previous</span>
    </a>

    <a
      :disabled="disabled || !nextPageActive"
      class="pagination-next"
      @click="goToNextPage"
    >
      <span>Next page</span>
      <span class="icon">
        <i class="fab fa fa-angle-double-right"></i>
      </span>
    </a>

    <ul class="pagination-list">
      <template v-for="(segment, position) in segments">
        <li
          v-if="segment.separator"
          :key="`sep-${position}`"
        >
          <span class="pagination-ellipsis">&hellip;</span>
        </li>

        <li
          v-for="item in segment.items"
          :key="`p-${item}`"
        >
          <a
            :aria-label="`Go to page ${item}`"
            class="pagination-link"
            :disabled="disabled"
            :class="{ 'is-current': item === currentPage }"
            @click="goToPage(item)"
          >{{ item }}</a>
        </li>
      </template>
    </ul>
  </nav>
</template>

<script>
  export default {
    props: {
      start: Number,
      finish: Number,
      total: Number,
      limit: Number,
      offset: Number,
      disabled: Boolean,
    },

    computed: {
      isVisible() {
        return this.pages > 1;
      },

      segments() {
        const current = this.currentPage;
        const total = this.pages;

        const segments = [
          { items: this.range(1, Math.min(total, 3)), separator: false },
          { items: [], separator: false },
          { items: [], separator: false },
        ];

        // start segment
        if (current > 3 && current < 5) {
          segments[0].items = this.range(1, current + 1);
        } else if (current >= 5) {
          segments[0].items = this.range(1, 1);
        }

        // middle segment
        if (current > 4) {
          segments[1].items = this.range(current - 1, Math.min(total - current + 1, 3));
          segments[1].separator = total > 3;
        }

        // last segment
        if (total > 5) {
          segments[2].items = this.range(total, 1);
          segments[2].separator = current < total - 1;
        }

        return segments;
      },

      currentPage() {
        return Math.floor(this.offset / this.limit) + 1;
      },

      nextPage() {
        const next = this.currentPage + 1;
        return next > this.pages ? null : next;
      },

      nextPageActive() {
        return this.nextPage !== null;
      },

      previousPage() {
        const previous = this.currentPage - 1;
        return previous < 1 ? null : previous;
      },

      previousPageActive() {
        return this.previousPage !== null;
      },

      pages() {
        return Math.ceil(this.total / this.limit);
      },
    },

    methods: {
      goToPage(page) {
        if (page === this.currentPage) return;
        this.$emit('turn-page', {
          limit: this.limit,
          offset: this.limit * (page - 1),
        });
      },

      goToPreviousPage() {
        const page = this.currentPage - 1;
        if (page > 0) this.goToPage(page);
      },

      goToNextPage() {
        const page = this.currentPage + 1;
        if (page <= this.pages) this.goToPage(page);
      },

      range(start, length) {
        return new Array(length).fill(0).map(() => start++);
      },
    },
  };
</script>
