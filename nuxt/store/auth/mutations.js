export default {
  set(state, token) {
    state.token = token;
  },
  unset(state) {
    state.token = null;
  },
};
