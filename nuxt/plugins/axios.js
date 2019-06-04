export default ({ $axios, store, redirect }) => {
  $axios.onError(async error => {
    if (store.getters['auth/logged']) {
      const statusCode = error.response.status;

      switch (statusCode) {
        case 401:
          store.commit('user/set');
          await store.dispatch('auth/logout');
          return redirect('/auth/login');
      }
    }

    throw error;
  });
};
