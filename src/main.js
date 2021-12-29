import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import VueShortkey from 'vue3-shortkey'
import VueClipboard from 'vue-clipboard2'
import Codemirror from 'codemirror-editor-vue3'

import apiConf from '@/assets/json/backend.json'
import localization from '@/assets/json/lang.json'

import eventBus from '@/eventBus.js'

const app = createApp(App)

app.use(router)
app.use(VueShortkey)
app.use(Codemirror)
app.use(VueClipboard)

window.bus = eventBus

app.mixin({
  data () {
    return {
      apiUrl: apiConf.api.url,
      localization: localization,
      lang: localization.default
    }
  },
  mounted () {
    window.bus.$on('langChange', value => {
      this.lang = value
    })
  }
})


app.mount('#app')
