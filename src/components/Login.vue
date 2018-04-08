<template>
  <div class="modal is-active" v-if="logged === false"
>
    <div class="modal-background"></div>
    <div class="modal-content has-text-centered">
      <div class="modal-card column is-8">
        <header class="modal-card-head">
          <div class="container has-text-grey">
            <h3 class="title has-text-grey">
              <i class="icon fa fa-sign-in"/>&nbsp;
            login</h3>
            <p> </p>
            <p class="subtitle has-text-grey">please login to proceed</p>
          </div>
        </header>
        <section class="modal-card-body">
          <div class="field">
            <div class="control is-large">
              <input
                class="input"
                type="text"
                placeholder="enter your login here"
                @keyup.enter="login()"
                @keyup="error=false"
                v-model="user"
              >
            </div>
          </div>
          <div class="field">
            <div class="control is-large">
              <input
                class="input"
                type="password"
                placeholder="and your password here"
                @keyup.enter="login()"
                @keyup="error=false"
                v-model="password"
              >
            </div>
          </div>
          <div class="field is-small">
            <label class="checkbox is-small">
              <input type="checkbox"/>
              remember me
            </label>
          </div>
        </section>
        <footer class="modal-card-foot">
          <div class="field is-fullwidth">
            <p class="control is-large">
              <a class="button is-fullwidth " 
                :class="[{'is-info': (error === false) && (logged === false)},
                         {'is-danger shake': error === true},
                         {'is-success': logged === true}]"
                @click="login()">
                <span class="icon" v-show="isLogginIn"><i class="fa fa-spinner fa-pulse" aria-hidden="true"></i></span>
                <span class="icon" v-show="logged"><i class="fa fa-check" aria-hidden="true"></i></span>
                <span class="icon" v-show="error"><i class="fa fa-times" aria-hidden="true"></i></span>
                <span> login </span>
              </a>
            </p>
          </div>
        </footer>
      </div>
    </div>
  </div>
</template>

<script>
import * as CryptoJS from 'crypto-js'

export default {
  name: 'login',
  data () {
    return {
      user: '',
      password: '',
      logged: true,
      isLogginIn: false,
      error: false
    }
  },
  calculated: {
    password_hash () {
      return CryptoJS.sha384(this.password)
    }
  },
  methods: {
    login () {
      this.isLoggingIn = true
      this.$http.post(this.apiUrl + 'login/', { user: this.user, password: CryptoJS.SHA384(this.password).toString(CryptoJS.enc.Hex) }).then((response) => {
        this.logged = true
        window.bus.$emit('reloadNav')
      },
      () => {
        this.error = true
      })
    }
  },
  created () {
    this.$http.get(this.apiUrl + 'login/').then((response) => {
      this.logged = true
      window.bus.$emit('reloadNav')
    },
    () => {
      this.logged = false
      window.bus.$emit('reloadNav')
    })
  }
}
</script>

<style lang="scss" scoped>
    .shake {
      -webkit-animation: kf_shake 0.4s 1 linear;
      -moz-animation: kf_shake 0.4s 1 linear;
      -o-animation: kf_shake 0.4s 1 linear;
    }

</style>
