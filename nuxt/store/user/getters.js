import { ROLE_ADMINISTRATOR, ROLE_USER, ROLE_ANONYMOUS } from './const';

export default {
  id: state => state.id,
  username: state => state.username,

  // roles
  isAdministrator: state => state.role === ROLE_ADMINISTRATOR,
  isUser: state => state.role === ROLE_USER || state.role === ROLE_ADMINISTRATOR,
  isAnonymous: state => state.role === ROLE_ANONYMOUS,
};
