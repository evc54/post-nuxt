import { rpc, getAll, getOne } from '~/helpers/axios';

const endpoint = 'users';

export default {
  async info({ state, commit }) {
    const response = await getOne(this.$axios, 'rpc/user_info');

    commit('set', response);

    return response;
  },

  create(_, data) {
    return rpc(this.$axios, 'rpc/new_user', {
      data,
      single: true,
      represent: true,
    });
  },

  switch(_, data) {
    return rpc(this.$axios, 'rpc/switch_role', { data });
  },

  password(_, data) {
    return rpc(this.$axios, 'rpc/change_password', { data });
  },

  delete(_, id) {
    return rpc(this.$axios, 'rpc/delete_user', { data: { id } });
  },

  all(_, { limit = 10, offset = 0, ...query } = {}) {
    return getAll(this.$axios, endpoint, {
      params: {
        select: '*,author_todo_count,author_done_count,author_todo_comment_count',
        order: 'created_at.desc,id.asc',
        limit,
        offset,
        ...query,
      },
    });
  },
};
