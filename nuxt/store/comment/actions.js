import { getAll, add, del } from '~/helpers/axios';

const endpoint = 'todo_comments';

export default {
  all(_, { limit = 5, offset = 0, ...query } = {}) {
    return getAll(this.$axios, endpoint, {
      params: {
        select: '*,todo_comment_author',
        order: 'created_at.asc,id.asc',
        limit,
        offset,
        ...query,
      },
    });
  },

  create(_, data) {
    return add(this.$axios, endpoint, { data });
  },

  delete(_, id) {
    return del(this.$axios, endpoint, {
      params: {
        id: `eq.${id}`,
      },
    });
  },
};
