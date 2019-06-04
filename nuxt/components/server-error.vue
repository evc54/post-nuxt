<template>
  <div
    v-show="error"
    class="notification is-danger"
  >
    {{ errorMessage }}

    <small v-if="errorHint">
      <br />
      {{ errorHint }}
    </small>
  </div>
</template>

<script>
  export default {
    props: {
      error: { type: Boolean, default: false },
      errorData: { type: [Error, Object], default: () => ({}) },
    },

    computed: {
      errorResponse() {
        const { response = {} } = this.errorData;
        return response;
      },

      errorResponseData() {
        const { data = {} } = this.errorResponse;
        return data;
      },

      errorMessage() {
        const { status, statusText } = this.errorResponse;
        const { message = null } = this.errorResponseData;
        return message || `${status}: ${statusText}`;
      },

      errorHint() {
        const { hint = null } = this.errorResponseData;
        return hint;
      },
    },
  };
</script>
