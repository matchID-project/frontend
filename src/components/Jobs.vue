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
                    :to="{ name: 'job', params: { job: job.recipe}}"
                  >
                  <span class="icon">
                    <i class="fa fa-spinner fa-spin"></i>
                  </span>
                  <span>{{ job.recipe }} <br/> {{ job.date }}</span>
                  </router-link>
                </li>
              </ul>
              <p class="menu-label">
                {{localization.navbar.jobs.done[lang]}}
              </p>
              <ul class="menu-list">
                <li v-if="$lodash.isEmpty(doneJobs)">
                  {{localization.navbar.jobs.empty[lang]}}
                </li>
                <li v-else v-for="(recipe, key) in groupedRecipes" :key="key">
                  <router-link
                    :to="{ name: 'job', params: { job: key}}"
                    :class="{'is-active' : key === $route.params.job}"
                  >
                    {{ key }}
                  </router-link>
                  <ul>
                    <li v-for="(joba, index) in recipe.slice(0,6)" :key="index">
                      <a class="mID-unclickable">{{ joba.date }}</a>
                    </li>
                    <li v-if="recipe.length > 6"><a class="mID-unclickable">...</a></li>
                  </ul>
                </li>
              </ul>
            </div>
          </aside>
          <div class="column is-8" v-if="$route.name === 'job' && log">
            <div class="box is-size-7">
              <article class="message is-danger" v-show="warningIndicator">
                <div class="message-header">
                  <p><span class="icon"><i class="fa fa-warning"></i></span> {{localization.viewLog.error[lang]}}</p>
                </div>
              </article>
              <pagination
                :pageSize="pageSize"
                :lengthData="arrLength"
                @pageChanged="v => {pageCurrent = v}"
              ></pagination>
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
      runningJobs: {},
      doneJobs: {},
      log: null,
      arrLength: 1,
      warningIndicator: false,
      // pagination
      pageSize: 100,
      pageCurrent: 1
    }
  },
  watch: {
    '$route.params.job' () {
      this.getLog(this.$route.params.job)
    }
  },
  mounted () {
    this.getJobs()

    window.bus.$on('updateJobs', v => {
      this.runningJobs = v.running
      this.doneJobs = v.done
    })

    if (this.$route.name === 'job') {
      this.getLog(this.$route.params.job)
    }
  },
  computed: {
    parsedLog () {
      if (this.log) {
        let arr = this.log.split('\n')
        this.warningIndicator = arr.some(v => { return v.match('Ooops') })
        this.arrLength = arr.length
        return arr.slice((this.pageCurrent - 1) * this.pageSize, this.pageCurrent * this.pageSize)
      }
    },
    groupedRecipes () {
      return this.$lodash.groupBy(this.doneJobs, v => { return v.recipe })
    }
  },
  methods: {
    getJobs () {
      this.$http.get(this.apiUrl + 'jobs')
        .then(response => {
          this.runningJobs = response.body.running
          this.doneJobs = response.body.done
        })
    },
    getLog (recipe) {
      this.$http.get(this.apiUrl + 'recipes/' + recipe + '/log')
        .then(response => {
          this.log = response.body
        })
    }
  }
}
</script>

<style lang="scss" scoped>
.hero.is-small > .hero-body{
  padding: 1rem 1.5rem;
}
</style>
