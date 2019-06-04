import { rpc } from '~/helpers/axios';

export default {
  signup({ getters }, data) {
    if (getters['isLogged']) return;

    return rpc(this.$axios, 'rpc/signup', { data, single: true });
  },

  async login({ getters, commit, dispatch }, data) {
    if (getters['isLogged']) return;

    const response = await rpc(this.$axios, 'rpc/login', { data, single: true });
    const { token = null } = response;

    commit('set', token);
    await dispatch('apply');

    return response;
  },

  logout({ getters, commit, dispatch }) {
    if (!getters['isLogged']) return;

    if (process.client) {
      const Cookie = require('js-cookie');
      Cookie.remove('jwt');
    }

    commit('unset');
    return dispatch('apply');
  },

  apply({ state }) {
    const { token } = state;

    if (token) {
      this.$axios.setToken(token, 'Bearer');
    } else {
      this.$axios.setToken(false);
    }
  },
};
