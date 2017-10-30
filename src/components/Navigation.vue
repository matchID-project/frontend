<template>
  <div id="navigationWrapper">
    <nav class="navbar is-transparent">
      <div class="navbar-brand">
        <router-link
          class="navbar-item logo"
          :to="{ name: 'root'}"
        >
          matchID
        </router-link>
        <div class="navbar-item has-dropdown is-hoverable">
          <a class="navbar-link is-active">
            <span class="icon"><i class="fa fa-globe"></i></span>
          </a>
          <div class="navbar-dropdown is-boxed">
            <a
              class="navbar-item"
              v-for="availableLang in langs"
              :key="availableLang.key"
              :class="{'is-active' : availableLang === lang}"
              @click="changeLang(availableLang)"
            >
              {{ availableLang.toUpperCase() }}
            </a>
          </div>
        </div>
      </div>

      <div class="navbar-menu">
        <div class="navbar-start">
          <div class="navbar-item has-dropdown is-hoverable">
            <router-link
              :to="{ name: 'jobs'}"
              class="navbar-link"
            >
              <span class="icon"><i class="fa fa-play" aria-hidden="true"></i></span>
              <span>Jobs</span>
            </router-link>

            <div class="navbar-dropdown is-boxed is-overflowed-y"  :style="dropdownMaxHeight">
              <div class="dropdown-item">
                <h6 class="title is-6 has-text-primary">{{localization.navbar.jobs.running[lang]}}</h6>
              </div>
              <hr class="dropdown-divider">
              <a class="navbar-item" v-for="(job, index) in runningJobs" :key="job.index">
                {{ job.recipe }} <br/> {{ job.date }}
              </a>
              <div class="navbar-item" v-if="$lodash.isEmpty(runningJobs)">
                {{localization.navbar.jobs.empty[lang]}}
              </div>
              <hr class="dropdown-divider">
              <div class="dropdown-item">
                <h6 class="title is-6 has-text-primary">{{localization.navbar.jobs.done[lang]}}</h6>
              </div>
              <hr class="dropdown-divider">
              <div class="navbar-item" v-if="$lodash.isEmpty(doneJobs)">
                {{localization.navbar.jobs.empty[lang]}}
              </div>
              <router-link
                :to="{ name: 'job', params: { job: job.recipe}}"
                v-else
                class="navbar-item" v-for="(job, index) in doneJobs.slice(0,10)" :key="job.index"
              >
                {{ job.recipe }} <br/> {{ job.date }}
              </router-link>
              <router-link
                :to="{ name: 'jobs' }"
                class="navbar-item has-text-link"
                v-if="doneJobs.length > 10"
              >
                {{localization.global.see_more[lang]}} ...
              </router-link>
            </div>
          </div>

          <div class="navbar-item has-dropdown is-hoverable">
            <router-link
              :to="{ name: 'home'}"
              class="navbar-link"
            >
              <span class="icon">
                <i class="fa fa-connectdevelop" aria-hidden="true"></i>
              </span>
              {{localization.navbar.projects[lang]}}
            </router-link>

            <div class="navbar-dropdown is-boxed is-overflowed-y" :style="dropdownMaxHeight">
              <a
                class="navbar-item has-text-info"
                @click="newObject = {display: true, type: 'project'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.new.project[lang] }}
              </a>

              <hr class="dropdown-divider">

              <a
                class="navbar-item has-text-info"
                @click="getProjects(); loadingProjects = true"
              >
                <span class="icon">
                  <i class ="fa fa-refresh"></i>
                </span>
                {{ localization.global.refresh_list[lang] }}
              </a>

              <hr class="dropdown-divider">

              <div class="has-text-centered" v-if="loadingProjects">
                <span class="icon has-text-black-bis is-medium">
                  <i class="fa fa-spinner fa-2x fa-spin"></i>
                </span>
              </div>

              <router-link
                class="navbar-item"
                v-else
                v-for="project in orderedProjects"
                :key="project.key"
                :class="{'is-active' : project === $route.params.project}"
                :to="{ name: 'project', params: { project: project}}"
              >
                {{ project }}
              </router-link>
            </div>
          </div>

          <div v-if="$route.params.project" class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link">
              <span class="icon">
                <i class="fa fa-table" aria-hidden="true"></i>
              </span>
              {{localization.navbar.datasets[lang]}}
            </a>

            <div class="navbar-dropdown is-boxed is-overflowed-y" :style="dropdownMaxHeight">
              <a
                class="navbar-item has-text-info"
                @click="newObject = {display: true, type: 'dataset'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.new.dataset[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="importObject={type: 'Dataset'}"
              >
                <span class="icon">
                  <i class ="fa fa-download"></i>
                </span>
                {{ localization.object.import.dataset[lang] }}
              </a>

              <hr class="dropdown-divider">

              <a
                class="navbar-item has-text-info"
                @click="getDatasets($route.params.project); loadingDatasets = true"
              >
                <span class="icon">
                  <i class ="fa fa-refresh"></i>
                </span>
                {{ localization.global.refresh_list[lang] }}
              </a>

              <hr class="dropdown-divider">

              <div class="has-text-centered" v-if="loadingDatasets">
                <span class="icon has-text-black-bis is-medium">
                  <i class="fa fa-spinner fa-2x fa-spin"></i>
                </span>
              </div>

              <router-link
                class="navbar-item"
                v-else
                v-for="(dataset, key) in orderedDatasets"
                :key="dataset.table"
                :class="{'is-active' : key === $route.params.dataset}"
                :to="{ name: 'dataset', params: { dataset: key}}"
              >
                <div class="level is-mobile">
                  <div class="level-left">
                    <div class="level-item">
                      <span class="icon">
                        <i
                          class="fa"
                          :class="[
                            {'fa-file-text-o' : dataset.connector == 'upload'},
                            {'fa-database' : dataset.connector == 'elasticsearch'},
                            {'fa-table' : dataset.connector == 'referential_data'}
                          ]"
                        ></i>
                      </span>
                    </div>
                  </div>
                  <div class="level-right">
                    <div class="level-item">
                      {{ key }}
                    </div>
                    <div class="level-item">
                      <span class="icon has-text-info">
                        <i
                          class="fa"
                          :class="{'fa-check has-text-primary' : dataset.validation}"
                          @click="displayGraph = true"
                        ></i>
                      </span>
                    </div>
                  </div>
                </div>
              </router-link>
            </div>
          </div>

          <div v-if="$route.params.project" class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link">
              <span class="icon">
                <i class="fa fa-flask" aria-hidden="true"></i>
              </span>
              {{localization.navbar.recipes[lang]}}
            </a>

            <div class="navbar-dropdown is-boxed is-overflowed-y" :style="dropdownMaxHeight">
              <a
                class="navbar-item has-text-info"
                @click="newObject = {display: true, type: 'recipe'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.new.recipe[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="importObject={type: 'Recipe'}"
              >
                <span class="icon">
                  <i class ="fa fa-download"></i>
                </span>
                {{ localization.object.import.recipe[lang] }}
              </a>

              <hr class="dropdown-divider">

              <a
                class="navbar-item has-text-info"
                @click="getRecipes($route.params.project); loadingRecipes = true"
              >
                <span class="icon">
                  <i class ="fa fa-refresh"></i>
                </span>
                {{ localization.global.refresh_list[lang] }}
              </a>

              <hr class="dropdown-divider">

              <div class="has-text-centered" v-if="loadingRecipes">
                <span class="icon has-text-black-bis is-medium">
                  <i class="fa fa-spinner fa-2x fa-spin"></i>
                </span>
              </div>

              <router-link
                class="navbar-item"
                v-else
                v-for="(recipe, key) in orderedRecipes"
                :key="recipe.table"
                :class="{'is-active' : key === $route.params.recipe}"
                :to="{ name: 'recipe', params: { recipe: key}}"
              >
                {{ key }}
              </router-link>
            </div>
          </div>
        </div>

        <div class="navbar-end">
          <div class="navbar-item" v-if="!loadingDatasets && $route.params.dataset && datasets[$route.params.dataset].validation">
            <router-link
              v-if="$route.name === 'dataset'"
              :to="{ name: 'validation'}"
              class="button is-link is-outlined"
            >
              <span class="icon"><i class="fa fa-check" aria-hidden="true"></i></span>
              <span>Validation</span>
            </router-link>

            <router-link
              v-if="$route.name === 'validation'"
              :to="{ name: 'dataset'}"
              class="button is-link is-outlined"
            >
              <span class="icon"><i class="fa fa-table" aria-hidden="true"></i></span>
              <span>Dataset</span>
            </router-link>
          </div>

          <div class="navbar-item" v-if="$route.params.recipe">
            <template v-if="recipeStatus === 'up'">
              <a
                v-if="stoppingStatus"
                class="button is-outlined is-danger"
                disabled
              >
                <span class="icon">
                  <i class="fa fa-spin fa-spinner"></i>
                </span>
                <span>{{localization.recipe.stopping[lang]}} ...</span>
              </a>
              <a
                v-else
                @mouseover="recipeState = 'stop'"
                @mouseleave="recipeState = 'running'"
                class="button is-outlined"
                :disabled="!clickPossible"
                :class="[
                  {'is-danger': recipeState === 'stop'},
                  {'is-warning' : recipeState === 'running'}
                ]"
                @click="stopRecipe($route.params.recipe)"
              >
                <span class="icon">
                  <i
                    class="fa"
                    :class="[
                      {'fa-ban': recipeState === 'stop'},
                      {'fa-spin fa-spinner' : recipeState === 'running'}
                    ]"
                  ></i>
                </span>
                <span v-if="recipeState === 'stop'">{{localization.recipe.stop[lang]}}</span>
                <span v-else-if="recipeState === 'running'">{{localization.recipe.running[lang]}} ...</span>
              </a>
            </template>
            <a
              v-else-if="recipeStatus"
              class="button is-success is-outlined"
              :disabled="!clickPossible"
              @click="runRecipe($route.params.recipe)"
            >
              <span class="icon"><i class="fa fa-play" aria-hidden="true"></i></span>
              <span>{{localization.recipe.run[lang]}}</span>
            </a>
          </div>
          <div class="navbar-item breadcrumb">
            <ul>
              <li>
                <span class="icon has-text-info">
                  <i
                    class="fa fa-connectdevelop mID-clickable"
                    @click="displayGraph = true"
                  ></i>
                </span>
                <a class="mID-unclickable">
                  <span>{{ $route.params.project }}</span>
                </a>
              </li>

              <li v-if="$route.params.recipe || $route.params.dataset">
                <a class="mID-unclickable">
                  {{ $route.params.recipe ? $route.params.recipe : '' }}{{ $route.params.dataset ? $route.params.dataset : '' }}
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </nav>

    <graph-view
      v-if="displayGraph"
      @close="displayGraph = false"
      :datasets="allDatasets"
      :recipes="allRecipes"
      :project="this.$route.params.project"
    ></graph-view>

    <new-object
      :display="newObject.display"
      :type="newObject.type"
      @close="newObject.display = false"
    ></new-object>

  </div>
</template>

<script>
import GraphView from './Graph'
import NewObject from './Object/New'

export default {
  components: {
    GraphView,
    NewObject
  },
  data () {
    let maxHeightCalc = window.screen.availHeight - 200
    return {
      langs: [],
      dropdownMaxHeight: {maxHeight: maxHeightCalc + 'px'},
      // projects
      projects: [],
      loadingProjects: true,
      // datasets
      datasets: {},
      allDatasets: {},
      loadingDatasets: true,
      // recipes
      recipes: {},
      allRecipes: {},
      loadingRecipes: true,
      recipeStatus: null,
      clickPossible: true,
      recipeState: 'running',
      stoppingStatus: false,
      interval: {},
      // graph
      displayGraph: false,
      // new object
      newObject: {
        display: false,
        type: null
      },
      // jobs
      runningJobs: {},
      doneJobs: {}
    }
  },
  mounted () {
    this.langs = this.localization.available

    this.changeLang(this.lang)

    this.getJobs()

    this.getProjects()

    this.getDependencies(this.$route.params.project)

    if (this.$route.params.recipe) {
      this.getStatus(this.$route.params.recipe)

      this.interval.status = setInterval(() => {
        this.getStatus(this.$route.params.recipe)
      }, 3000)
    }

    this.interval.jobs = setInterval(() => {
      this.getJobs()
    }, 3000)

    window.bus.$on('reloadNav', () => {
      this.getProjects()
      this.getDependencies(this.$route.params.project)
    })
  },
  beforeDestroy () {
    clearInterval(this.interval)
  },
  watch: {
    '$route.params.project' () {
      this.getDependencies(this.$route.params.project)
    },
    '$route.params.recipe' () {
      this.recipeStatus = null
    },
    '$route.name' (newVal) {
      if (newVal === 'recipe') {
        this.interval.status = setInterval(() => {
          this.getStatus(this.$route.params.recipe)
        }, 3000)
      } else {
        clearInterval(this.interval)
      }
    }
  },
  computed: {
    orderedProjects () {
      return this.$lodash.sortBy(this.projects)
    },
    orderedDatasets () {
      let ordered = {}
      this.$lodash(this.datasets).keys().sort().each(key => {
        ordered[key] = this.datasets[key]
      })
      return ordered
    },
    orderedRecipes () {
      let ordered = {}
      this.$lodash(this.recipes).keys().sort().each(key => {
        ordered[key] = this.recipes[key]
      })
      return ordered
    }
  },
  methods: {
    changeLang (newLang) {
      this.lang = newLang
      window.bus.$emit('langChange', this.lang)
    },
    getProjects () {
      this.$http.get(this.apiUrl + 'conf')
        .then(response => {
          this.projects = Object.keys(response.body.projects)
          setTimeout(() => { this.loadingProjects = false }, 500)
        })
    },
    getDependencies (project) {
      this.getDatasets(project)

      this.getRecipes(project)
    },
    getDatasets (project) {
      this.$http.get(this.apiUrl + 'datasets')
        .then(response => {
          this.allDatasets = response.body
          this.datasets = this.$lodash.pickBy(response.body, (v) => v.project === project)
          setTimeout(() => { this.loadingDatasets = false }, 500)
        })
    },
    getRecipes (project) {
      this.$http.get(this.apiUrl + 'recipes')
        .then(response => {
          this.allRecipes = response.body
          this.recipes = this.$lodash.pickBy(response.body, (v) => v.project === project)
          setTimeout(() => { this.loadingRecipes = false }, 500)
        })
    },
    runRecipe (recipe) {
      this.clickPossible = false
      this.stoppingStatus = false
      this.$http.put(this.apiUrl + 'recipes/' + recipe + '/run')
        .then(response => {
          setTimeout(() => { this.clickPossible = true }, 6 * 1000)
        })
    },
    stopRecipe (recipe) {
      this.clickPossible = false
      this.stoppingStatus = true

      this.$http.put(this.apiUrl + 'recipes/' + recipe + '/stop')
        .then(response => {
          this.clickPossible = true
        })
    },
    getStatus (recipe) {
      this.$http.get(this.apiUrl + 'recipes/' + recipe + '/status')
        .then(response => {
          this.recipeStatus = response.body.status
          if (this.recipeStatus === 'down') {
            this.stoppingStatus = false
          }
        })
    },
    getJobs () {
      this.$http.get(this.apiUrl + 'jobs')
        .then(response => {
          this.runningJobs = response.body.running
          this.doneJobs = response.body.done
          if (this.$route.name === 'jobs' || this.$route.name === 'job') {
            window.bus.$emit('updateJobs', {running: response.body.running, done: response.body.done})
          }
        })
    }
  }
}
</script>

<style scoped lang="scss">

</style>
