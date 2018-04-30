<template>
  <div id="jobs">
    <div class="hero">
      <section class="hero is-info">
        <div class="hero-body">
          <div class="container">
            <h1 class="title">
              Jobs
            </h1>
          </div>
        </div>
      </section>
    </div>
    <section class="section">
      <div class="container">
        <div class="columns">
          <aside class="column is-4">
            <div class="menu box">
              <p class="menu-label">
                {{localization.navbar.jobs.running[lang]}}
              </p>
              <ul class="menu-list">
                <li v-if="$lodash.isEmpty(runningJobs)">
                  {{localization.navbar.jobs.empty[lang]}}
                </li>
                <li v-else v-for="(job, key) in runningJobs" :key="key">
                  <router-link
                    :to="{ name: 'job', params: { job: job.recipe }}"
                    :class="{'is-active' : job.recipe === $route.params.job}"
                  >
                    <div class="level ">
                      <div class="level-left">
                        <div class="level-item">
                          <div>
                            <p>{{ job.recipe }}</p>
                            <p class="heading">{{ job.date }}</p>
                          </div>
                        </div>
                      </div>
                      <div class="level-right">
                        <div class="icon">
                          <i class="fa fa-spinner fa-spin"></i>
                        </div>
                      </div>                      
                   </div>
                  </router-link>
                </li>
              </ul>
              <p class="menu-label">
                {{localization.navbar.jobs.done[lang]}}
              </p>
              <div class="menu-list">
                <p v-if="$lodash.isEmpty(doneJobs)">
                  {{localization.navbar.jobs.empty[lang]}}
                </p>
                <p v-else v-for="(recipe, key) in groupedRecipes" :key="key">
                  <router-link
                    :to="{ name: 'job', params: { job: key}}"
                    :class="{'is-active' : key === $route.params.job}"
                  >
                    {{ key }}
                  </router-link>
                  <ul>
                    <p v-for="(joba, index) in recipe.slice(0,6)" :key="index" class="heading">
                       &nbsp; &nbsp; {{ joba.date }}
                    </p>
                    <p v-if="recipe.length > 6" class="heading">&nbsp; &nbsp; ...</p>
                  </ul>
                </p>
              </div>
            </div>
          </aside>
          <div class="column is-8" v-if="$route.name === 'job' && log">
            <div class="box is-size-7">
              <article class="message is-danger" v-show="warningIndicator">
                <div class="message-header">
                  <p><span class="icon"><i class="fa fa-warning"></i></span> {{localization.viewLog.error[lang]}}</p>
                </div>
              </article>
              <div class="field is-horizontal">
                <div class="field-body">
                  <pagination
                    :pageSize="pageSize"
                    :lengthData="arrLength"
                    :pageCurrent="pageCurrent"
                    @pageChanged="setPageCurrent"
                  ></pagination>
                  <div class="field is-narrow">
                    <p class="control is-expanded has-icons-left">
                      <input
                        v-model="filter"
                        class="input is-small"
                        type="text"
                        :placeholder="localization.navbar.jobs.filter[lang]"
                      >
                      <span class="icon is-small is-left">
                        <i class="fa fa-filter"></i>
                      </span>
                    </p>
                  </div>

                </div>
              </div>
              <div
                v-for="line in parsedLog"
                v-show="line"
                :key="line"
                :class="{'has-text-danger' : line.match('Ooops')}"
              >
                <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
                <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
                <span>{{ line }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import Pagination from './Helpers/Pagination'

export default {
  components: {
    Pagination
  },
  data () {
    return {
      evtSource: null,
      runningJobs: {},
      doneJobs: {},
      log: null,
      arrLength: 1,
      warningIndicator: false,
      warningNumber: 0,
      warningFilter: false,
      filter: '',
      // pagination
      pageSize: 20,
      pageCurrent: 1,
      interval: {}
    }
  },
  beforeDestroy () {
    clearInterval(this.interval)
  },
  watch: {
    '$route.params.job' () {
      this.getLog(this.$route.params.job)
    }
  },
  created () {
    this.getJobs()
  },
  mounted () {
  },
  computed: {
    filteredLog () {
      return this.log.filter(v => { return v.match(this.filter) })
    },
    parsedLog () {
      if (this.log) {
        let arr = this.filteredLog
        this.warningNumber = arr.filter(v => { return v.match('Ooops') }).length
        this.warningIndicator = (this.warningNumber > 0)
        this.arrLength = arr.length
        let pageMax = Math.max(1, Math.min(this.pageCurrent, Math.ceil((arr.length - 1) / this.pageSize)))
        if (pageMax < this.pageCurrent) {
          this.setPageCurrent(pageMax)
        }
        return arr.slice((this.pageCurrent - 1) * this.pageSize, this.pageCurrent * this.pageSize)
      }
    },
    groupedRecipes () {
      return this.$lodash.groupBy(this.doneJobs, v => { return v.recipe })
    }
  },
  methods: {
    setPageCurrent (page) {
      this.pageCurrent = page
      this.$emit('pageChanged', page)
    },
    getJobs () {
      this.$http.get(this.apiUrl + 'jobs')
        .then(response => {
          this.runningJobs = response.body.running
          this.doneJobs = response.body.done
          if (this.$route.name === 'job') {
            this.getLog(this.$route.params.job)
          }
        })
    },
    getLog (recipe) {
      if (this.runningJobs.some(r => { return r.recipe === recipe })) {
        this.getRunningLog(recipe)
      } else {
        this.$http.get(this.apiUrl + 'recipes/' + recipe + '/log')
          .then(response => {
            let arr = response.body.split('\n')
            if ((this.log === null) || (arr.length !== this.log.length)) {
              this.log = arr
              this.setPageCurrent(Math.ceil(this.log.length / this.pageSize))
            }
          })
        if (this.evtSource !== null) {
          this.evtSource.close()
        }
      }
    },
    getRunningLog (recipe) {
      this.evtSource = new EventSource(this.apiUrl + 'recipes/' + recipe + '/log')
      let that = this
      this.evtSource.addEventListener('open', function (e) {
        that.log = []
      }, false)
      this.evtSource.addEventListener('message', function (e) {
        that.log = that.log.concat(e.data.split('\n'))
        that.setPageCurrent(Math.ceil(that.log.length / that.pageSize))
      }, false)
      this.evtSource.addEventListener('close', function (e) {
        that.evtSource.close()
      }, false)
    }
  }
}
</script>

<style lang="scss" scoped>
.hero.is-small > .hero-body{
  padding: 1rem 1.5rem;
}
</style>
