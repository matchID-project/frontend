import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import VueShortkey from 'vue-shortkey'
import VueClipboard from 'vue-clipboard2'

import apiConf from '@/assets/json/backend.json'
import localization from '@/assets/json/lang.json'


const app = createApp(App)

app.use(router)
app.use(VueShortkey)
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
