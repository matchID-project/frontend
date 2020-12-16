<template>
  <div class="modal is-active" v-if="logged === false"
>
    <div class="modal-background"></div>
    <div class="modal-content has-text-centered">
      <div class="modal-card column is-8">
        <header class="modal-card-head" >
          <div class="container has-text-grey has-text-centered">
            <h3 class="title has-text-grey">
              <i class="icon fa fa-sign-in"/>&nbsp;
            {{localization.login.title[lang]}}</h3>
            <p> </p>
            <p class="is-small has-text-grey">{{localization.login.subtitle[lang]}}</p>
          </div>
        </header>
        <section class="modal-card-body">
          <figure style="padding-bottom:20px;margin-top:0px;" >
            <div style="overflow:hidden;height:132px;width:132px;padding: 5px;margin-left: auto;margin-right: auto;background: #fff;border-radius: 50%;box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1), 0 0 0 1px rgba(10, 10, 10, 0.1);">
              <img class="image is-128x128" style="margin-top:-5px;" src="../assets/img/matchID-logo-square.svg">
            </div>
          </figure>
          <div class="field">
            <div class="control is-large">
              <input
                class="input"
                type="text"
                :placeholder="localization.login.placeholder.id[lang]"
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
                :placeholder="localization.login.placeholder.password[lang]"
                @keyup.enter="login()"
                @keyup="error=false"
                v-model="password"
              >
            </div>
          </div>
          <!-- <div class="field is-small">
            <label class="checkbox is-small">
              <input type="checkbox">
              {{ localization.login.remember[lang] }}
            </input>
            </label>
          </div> -->
        </section>
        <footer class="modal-card-foot">
          <div class="field is-fullwidth">
            <p class="control">
              <a class="button is-large is-fullwidth"
                :class="[{'is-primary': (error === false) && (logged === false)},
                         {'is-danger': error === true},
                         {'is-success': logged === true}]"
                @click="login()">
                <span class="icon" v-show="isLogginIn"><i class="fa fa-spinner fa-pulse" aria-hidden="true"></i></span>
                <span class="icon" v-show="logged"><i class="fa fa-check" aria-hidden="true"></i></span>
                <span class="icon" v-show="error"><i class="fa fa-times" aria-hidden="true"></i></span>
                <span> {{ localization.login.button[lang] }} </span>
              </a>
              <a
                v-for="(provider, name) in socialProvidersActive"
                :key="name"
                class="button is-fullwidth"
                :class="provider.color"
                :href="apiUrl+'authorize/'+name">
              <span> <i class="icon fa" :class="provider.icon"/> {{ localization.login[name][lang] }} </span>
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
      error: false,
      socialProviders: {
        github: {
          active: false,
          color: 'is-dark',
          icon: 'fa-github'
        },
        facebook: {
          active: false,
          color: 'is-link',
          icon: 'fa-facebook'
        }
      }
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
        window.bus.$emit('changeUser', response.body.user)
        if (this.$route.name === 'login') {
          this.$router.push({name: 'home'})
        }
      },
      () => {
        this.error = true
      })
    }
  },
  created () {
    console.log('creation ici')
    this.$http.get(this.apiUrl + 'authorize/').then((response) => {
      response.body.providers.forEach(provider => {
        this.socialProviders[provider].active = true
      })
    })
    this.$http.get(this.apiUrl + 'login/').then((response) => {
      this.logged = true
      window.bus.$emit('changeUser', response.body && response.body.user)
    },
    () => {
      this.logged = false
    })
  },
  computed: {
    socialProvidersActive () {
      let dic={};
      Object.keys(this.socialProviders).forEach(name => {
        if (this.socialProviders[name].active) {
          dic[name] = this.socialProviders[name];
        }
      });
      return dic;
    }

  }
}
</script>

<style lang="scss" scoped>
html, body {
  font-family: 'Open Sans', serif;
  font-size: 14px;
  font-weight: 300;
}
.modal-card-body {
  z-index: 10000;
}
.avatar {
  margin-top: 0px;
  padding-bottom: 20px;
}
.avatar img {
  padding: 5px;
  margin-left: auto;
  margin-right: auto;
  background: #fff;
  border-radius: 50%;
  -webkit-box-shadow: 0 2px 3px rgba(10,10,10,.1), 0 0 0 1px rgba(10,10,10,.1);
  box-shadow: 0 2px 3px rgba(10,10,10,.1), 0 0 0 1px rgba(10,10,10,.1);
}
.span {
  font-weight: 300;
}
.input {
  font-weight: 300;
}
.button {
  font-weight: 700;
}

</style>
