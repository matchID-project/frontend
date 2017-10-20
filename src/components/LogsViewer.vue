<template>
  <div class="is-fullheight" id="LogsViewer">
    <div class="level is-fullheight loading-border" v-if="loading">
      <div class="level-item">
        <span class="icon">
          <i class="fa fa-spinner fa-spin"></i>
        </span>
        <span>Loading logs</span>
      </div>
    </div>
    <div class="box is-overflowed is-fullheight is-size-7" v-else>
      <div class="tabs is-small is-centered">
        <ul>
          <li :class="{'is-active' : tab === 'test'}" @click="tab = 'test'">
            <a>
              <span class="icon" :class="warningIndicatorTest ? 'has-text-danger' : 'has-text-success'">
                <i
                  class="fa"
                  :class="warningIndicatorTest ? 'fa-times' : 'fa-check'"
                ></i>
              </span>
              <span>Test Logs</span>
            </a>
          </li>
          <li :class="{'is-active' : tab === 'real'}" @click="tab = 'real'">
            <a>
              <span class="icon" :class="warningIndicatorReal ? 'has-text-danger' : 'has-text-success'">
                <i
                  class="fa"
                  :class="warningIndicatorReal ? 'fa-times' : 'fa-check'"
                ></i>
              </span>
              <span>Real Logs</span>
            </a>
          </li>
        </ul>
      </div>
      <div class="columns" v-if="tab === 'test'">
        <div class="column is-11">
            <div
              v-for="(line, index) in arrayTestLogs"
              v-if="index + 1 !== arrayTestLogs.length"
              :key="line.index"
              :class="{'has-text-danger is-size-6' : line.match('Ooops')}"
            >
              <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
              <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
              <span>{{ line }}</span>
            </div>
        </div>
        <div
          class="column is-1"
          :class="warningIndicatorTest ? 'has-background-red' : 'has-background-green'"
        >
        </div>
      </div>
      <div class="columns" v-if="tab === 'real'">
        <div class="column is-11">
            <div
              v-for="(line, index) in arrayRealLogs"
              v-if="index + 1 !== arrayRealLogs.length"
              :key="line.index"
              :class="{'has-text-danger is-size-6' : line.match('Ooops')}"
            >
              <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
              <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
              <span>{{ line }}</span>
            </div>
        </div>
        <div
          class="column is-1"
          :class="warningIndicatorReal ? 'has-background-red' : 'has-background-green'"
        >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    content: String,
    loading: Boolean
  },
  data () {
    return {
      warningIndicatorTest: false,
      warningIndicatorReal: false,
      realLogs: '',
      tab: 'test',
      interval: null
    }
  },
  mounted () {
    this.getRealLogs(this.$route.params.recipe)

    this.interval = setInterval(() => {
      this.getRealLogs(this.$route.params.recipe)
    }, 3000)
  },
  beforeDestroy () {
    clearInterval(this.interval)
  },
  computed: {
    arrayTestLogs () {
      let arr = this.content.split('\n')
      this.warningIndicatorTest = arr.some(v => { return v.match('Ooops') })
      return arr
    },
    arrayRealLogs () {
      let arr = this.realLogs.split('\n')
      this.warningIndicatorReal = arr.some(v => { return v.match('Ooops') })
      return arr
    }
  },
  methods: {
    getRealLogs (recipe) {
      this.$http.get(this.apiUrl + 'recipes/' + recipe + '/log')
        .then(response => {
          this.realLogs = response.body
        })
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
