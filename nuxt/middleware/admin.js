export default ({ store, redirect, error }) => {
  if (!store.getters['auth/isLogged']) {
    return redirect('/auth/login');
  }

  if (!store.getters['user/isAdministrator']) {
    return error({ statusCode: 403, message: 'access is forbidden' });
  }
};
