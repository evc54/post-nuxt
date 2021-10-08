const rootOpts = { root: true };

export default {
  async nuxtServerInit({ commit, dispatch }, { req }) {
    if (!req.headers.cookie) return;

    const cookieparser = require('cookieparser');
    const cookies = cookieparser.parse(req.headers.cookie);
    const { jwt = null } = cookies;
    if (!jwt) return;

    commit('auth/set', jwt, rootOpts);
    await dispatch('auth/apply');

    const user = await dispatch('user/info', null, rootOpts);
    if (user.status === 'error') {
      return dispatch('auth/logout', null, rootOpts);
    }
  },

  async nuxtClientInit({ dispatch }) {
    await dispatch('auth/apply', null, rootOpts);
  },
};
