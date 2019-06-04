<template>
  <div class="field">
    <label
      :for="inputId"
      class="label"
    >{{ label }}</label>

    <div class="control">
      <input
        v-model="username"
        :disabled="disabled"
        :id="inputId"
        type="text"
        class="input is-medium"
        :class="{ 'is-danger': !isValid }"
      />
    </div>

    <p
      v-show="!isValid"
      class="help is-danger"
    >{{ message }}</p>
  </div>
</template>

<script>
  export default {
    props: {
      value: { type: String, default: '' },
      label: { type: String, default: 'Username' },
      disabled: { type: Boolean, default: false },
    },

    data: () => ({
      isValid: true,
      message: '',
    }),

    computed: {
      username: {
        get() {
          return this.value;
        },

        set(newVal) {
          this.resetValidation();
          this.$emit('input', newVal);
        },
      },

      inputId() {
        return `username-${this._uid}`;
      },
    },

    methods: {
      validate() {
        this.resetValidation();

        this.validateEmpty();
        this.validateMinLength();
        this.validateMaxLength();
        this.validateContent();

        return this.isValid;
      },

      validateEmpty() {
        if (!this.isValid || this.value !== '') return;
        this.message = 'username can not be empty';
        this.isValid = false;
      },

      validateMinLength() {
        if (!this.isValid || this.value.length > 3) return;
        this.message = 'username can not be shorter than 4 symbols';
        this.isValid = false;
      },

      validateMaxLength() {
        if (!this.isValid || this.value.length < 11) return;
        this.message = 'username can not be longer than 10 symbols';
        this.isValid = false;
      },

      validateContent() {
        const contentRegExp = /[A-Za-z0-9]+/;
        if (!this.isValid || contentRegExp.test(this.value)) return;
        this.message = 'username can take alphanumeric characters only';
        this.isValid = false;
      },

      resetValidation() {
        this.isValid = true;
        this.message = '';
      },
    },
  };
</script>
