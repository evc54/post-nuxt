export default {
  isLogged: state => !!state.token,
  token: state => state.token,
};
