export default {
  inserted: el => {
    el.innerHTML = el.innerHTML.replace(/\n/g, '<br />');
  },
};
