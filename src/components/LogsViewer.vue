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
    <div class="box is-overflowed-y is-fullheight is-size-7" v-else>
      <div class="columns">
        <div class="column is-11">
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
          <div v-if="tab === 'test'">
            <div
              v-for="(line, index) in arrayTestLogs.filter((l, i) => i + 1 !== arrayTestLogs.length)"
              :key="index"
              :class="{'has-text-danger is-size-6' : line.match('Ooops')}">
              <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
              <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
              <span>{{ line }}</span>
            </div>
          </div>
          <div v-if="tab === 'real'">
            <div
              v-for="(line, index) in arrayRealLogs.filter((l, i) => (i + 1 !== arrayRealLogs.length) && ((i <= 100) || (i > (arrayRealLogs.length - 100))))"
              :key="index"
              :class="{'has-text-danger is-size-6' : line.match('Ooops')}">
              <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
              <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
              <span v-if="index != 100">{{ line }}</span>
              <span v-else> &lt;&lt;&lt; complete logs were cut for display performance &gt;&gt;&gt; </span>
            </div>
          </div>
        </div>
        <div class="column is-1"
          :class="((warningIndicatorReal && (tab === 'real')) || (warningIndicatorTest && (tab === 'test'))) ? 'has-background-red' : 'has-background-green'">
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
      evtSource: null,
      realLogs: '',
      realLogsLoading: false,
      lastLogsLoaded: false,
      tab: 'test',
      interval: null
    }
  },
  mounted () {
    window.bus.$on('runningRecipeLogs', () => {
      this.getRunningLogs(this.$route.params.recipe)
    })
    window.bus.$on('lastRecipeLogs', () => {
      this.getLastLogs(this.$route.params.recipe)
    })
  },
  beforeDestroy () {
    clearInterval(this.interval)
  },
  computed: {
    arrayTestLogs () {
      let arr = this.content.split('\n')
      return arr
    },
    arrayRealLogs () {
      let arr = this.realLogs.split('\n').reverse().filter(l => { return l.length > 0 })
      return arr
    },
    warningIndicatorTest () {
      return this.arrayTestLogs.some(v => { return v.match('Ooops') })
    },
    warningIndicatorReal () {
      return this.arrayRealLogs.some(v => { return v.match('Ooops') })
    }
  },
  methods: {
    getLastLogs (recipe) {
      if (this.lastLogsLoaded) {
        return
      }
      this.lastLogsLoaded = true
      this.$http.get(this.apiUrl + 'recipes/' + recipe + '/log').then(response => {
        this.realLogs = response.body
        this.realLogsLoading = false
      },
      () => {
      })
    },
    getRunningLogs (recipe) {
      if (this.realLogsLoading) {
        return
      }
      this.evtSource = new EventSource(this.apiUrl + 'recipes/' + recipe + '/log')
      this.realLogsLoading = true
      let that = this
      this.evtSource.addEventListener('open', function () {
        that.tab = 'real'
        that.realLogs = 'Recipe is currently processing\n'
      }, false)
      this.evtSource.addEventListener('message', function (e) {
        that.realLogs = that.realLogs + e.data + '\n'
      }, false)
      this.evtSource.addEventListener('close', function () {
        that.evtSource.close()
        that.realLogsLoading = false
      }, false)
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
