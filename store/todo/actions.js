import { getOne, getAll, add, mark } from '~/helpers/axios';

const endpoint = 'todos';

export default {
  one(_, id) {
    return getOne(this.$axios, endpoint, {
      params: {
        select: '*,todo_author',
        id: `eq.${id}`,
        limit: 1,
      },
    });
  },

  all(_, { limit = 10, offset = 0, ...query } = {}) {
    return getAll(this.$axios, endpoint, {
      params: {
        select: '*,todo_comment_count,todo_author',
        order: 'created_at.desc,id.asc',
        limit,
        offset,
        ...query,
      },
    });
  },

  create(_, data) {
    return add(this.$axios, endpoint, {
      data,
      single: true,
      represent: true,
    });
  },

  markAs(_, { id, newState }) {
    return mark(this.$axios, endpoint, {
      data: {
        done: newState,
      },
      config: {
        params: {
          id: `eq.${id}`,
        },
      },
    });
  },
};
