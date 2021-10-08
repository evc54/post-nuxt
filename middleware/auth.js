export default ({ store, redirect }) => {
  if (!store.getters['auth/isLogged']) {
    return redirect('/auth/login');
  }
};
