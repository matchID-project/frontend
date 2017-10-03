<template>
  <div id="app">
    <header>
      <match-id-navigation></match-id-navigation>
    </header>

    <router-view></router-view>

  </div>
</template>

<script>
import matchIdNavigation from './components/Navigation'
import Vue from 'vue'
import VueCodeMirror from 'vue-codemirror'

import apiConf from './assets/json/backend.json'
Vue.use(VueCodeMirror)

window.bus = new Vue()

Vue.mixin({
  data () {
    return {
      localization: localization,
      lang: localization.default
    }
  },
  mounted () {
    let self = this
    window.bus.$on('langChange', function (value) {
      self.lang = value
    })
  }
})

export default {
  name: 'app',
  components: {
    matchIdNavigation
  }
}
</script>

<style lang="scss" src="./assets/scss/style.scss"></style>
