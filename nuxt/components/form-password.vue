<template>
  <div class="field">
    <label
      :for="inputId"
      class="label"
    >{{ label }}</label>

    <div class="control">
      <input
        v-model="password"
        :disabled="disabled"
        :id="inputId"
        type="password"
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
      label: { type: String, default: 'Password' },
      disabled: { type: Boolean, default: false },
    },

    data: () => ({
      isValid: true,
      message: '',
    }),

    computed: {
      password: {
        get() {
          return this.value;
        },

        set(newVal) {
          this.resetValidation();
          this.$emit('input', newVal);
        },
      },

      inputId() {
        return `password-${this._uid}`;
      },
    },

    methods: {
      validate() {
        this.resetValidation();

        this.validateEmpty();
        this.validateMinLength();
        this.validateMaxLength();

        return this.isValid;
      },

      validateEmpty() {
        if (!this.isValid || this.value !== '') return;
        this.message = 'password can not be empty';
        this.isValid = false;
      },

      validateMinLength() {
        if (!this.isValid || this.value.length > 5) return;
        this.message = 'password can not be shorter than 6 symbols';
        this.isValid = false;
      },

      validateMaxLength() {
        if (!this.isValid || this.value.length < 17) return;
        this.message = 'password can not be longer than 16 symbols';
        this.isValid = false;
      },

      resetValidation() {
        this.isValid = true;
        this.message = '';
      },
    },
  };
</script>
