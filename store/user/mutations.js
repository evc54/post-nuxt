import { ROLE_ANONYMOUS } from './const';

export default {
  set(state, { id = null, username = null, role = ROLE_ANONYMOUS } = {}) {
    state.id = id;
    state.username = username;
    state.role = role;
  },
};
