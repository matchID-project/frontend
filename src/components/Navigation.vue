<template>
  <div id="navigationWrapper">
    <div class="navbar is-transparent">
      <div class="navbar-brand">
        <router-link class="logo" :to="{ name: 'root'}">
          <img class="logo mID-margin-right-8" src="../assets/img/matchID-logo.svg">
          <span class="logo mID-margin-right-8"/>
        </router-link>
        <div class="navbar-item is-hidden-touch has-dropdown is-hoverable">
            <a class="navbar-link">
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
        <div class="navbar-burger burger" :class="[{'is-active': burger}]" @click="burger = !burger" data-target="navMenubd-main">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
      <div id="navMenubd-main" class="navbar-menu" :class="[{'is-active': burger}]" >
        <div class="navbar-start">
          <div v-if="false" class="navbar-item has-dropdown is-hoverable">
            <router-link
              :to="{name: 'home'}"
              class="navbar-link"
            >
              <span class="icon">
                <i class="fa fa-plug" aria-hidden="true"></i>
              </span>
              {{localization.navbar.connectors[lang]}}
            </router-link>

            <div class="navbar-dropdown is-boxed is-overflowed-y" :style="dropdownMaxHeight">
              <a
                class="navbar-item has-text-info"
                @click="newObject = {display: true, type: 'connector'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.new.connector[lang] }}
              </a>

              <hr class="dropdown-divider">

              <a
                class="navbar-item has-text-info"
                @click="getConnectors()"
              >
                <span class="icon">
                  <i class ="fa fa-refresh"></i>
                </span>
                {{ localization.global.refresh_list[lang] }}
              </a>

              <hr class="dropdown-divider">

              <div class="has-text-centered" v-if="loadingConnectors">
                <span class="icon has-text-black-bis is-medium">
                  <i class="fa fa-spinner fa-2x fa-spin"></i>
                </span>
              </div>

              <router-link
                class="navbar-item"
                v-else
                v-for="connector in connectors"
                :key="connector.key"
                :class="{'is-active' : connector === $route.params.connector}"
                :to="{ name: 'connector', params: { connector: connector}}"
              >
                {{ connector }}
              </router-link>
            </div>
          </div>

          <div class="navbar-item has-dropdown is-hoverable" :class="[{'is-hidden-touch' : $route.params.project}]">
            <router-link
              :to="{name: 'home'}"
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
                @click="getProjects()"
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
                v-for="project in projects"
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
                <i class="fa fa-table" aria-hidden="true"/>
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
                @click="importObjectDisplay = true"
              >
                <span class="icon">
                  <i class ="fa fa-cloud-upload"></i>
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
                            {'fa-file' : dataset.connector === 'upload'},
                            {'fa-table' : dataset.connector === 'referential_data'},
                            {'fa-database' : dataset.connector === 'elasticsearch'},
                            {'fa-database' : dataset.connector === 'postgres'},
                            {'fa-database' : dataset.connector === 'redisearch'}
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
                  <i class="fa fa-flask" aria-hidden="true"/>
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
            <div class="navbar-item has-dropdown is-hoverable">
              <router-link
                :to="{ name: 'jobs'}"
                class="navbar-link"
              >
                <span class="icon"><i class="fa fa-play" aria-hidden="true"></i></span>
                <span>Jobs</span>
              </router-link>

              <div class="navbar-dropdown is-boxed is-overflowed-y"
                  :style="dropdownMaxHeight"
                  @mouseover="getJobs()">

                <a
                  class="navbar-item has-text-info"
                  @click="shutdown"
                >
                  <span class="icon">
                    <i class ="fa fa-stop"></i>
                  </span>
                  {{ localization.global.shutdown[lang] }}
                </a>

                <hr class="dropdown-divider">

                <div class="dropdown-item">
                  <h6 class="title is-6 has-text-primary">{{localization.navbar.jobs.running[lang]}}</h6>
                </div>
                <hr class="dropdown-divider">
                <router-link
                  :to="{ name: 'job', params: { job: job.recipe}}"
                  class="navbar-item" v-for="job in runningJobs" :key="job.index"
                >
                  {{ job.recipe }} <br/> {{ job.date }}
                </router-link>
                <div class="navbar-item" v-if="isEmpty(runningJobs)">
                  {{localization.navbar.jobs.empty[lang]}}
                </div>
                <hr class="dropdown-divider">
                <div class="dropdown-item">
                  <h6 class="title is-6 has-text-primary">{{localization.navbar.jobs.done[lang]}}</h6>
                </div>
                <hr class="dropdown-divider">
                <div class="navbar-item" v-if="isEmpty(doneJobs)">
                  {{localization.navbar.jobs.empty[lang]}}
                </div>
                <router-link
                  :to="{ name: 'job', params: { job: job.recipe}}"
                  v-else
                  class="navbar-item" v-for="job in doneJobs.slice(0,10)" :key="job.index"
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
        </div>
        <div class="navbar-end">
          <div class="navbar-item" v-if="!loadingDatasets && $route.params.dataset && datasets[$route.params.dataset].validation">
            <router-link
              v-if="$route.name === 'dataset'"
              :to="{ name: 'validation'}"
              class="button is-link is-outlined"
            >
              <span class="icon"><i class="fa fa-check" aria-hidden="true"></i></span>
              <span>{{localization.dataset.validation[lang]}}</span>
            </router-link>

            <router-link
              v-if="$route.name === 'validation'"
              :to="{ name: 'dataset'}"
              class="button is-link is-outlined"
            >
              <span class="icon"><i class="fa fa-table" aria-hidden="true"></i></span>
              <span>{{localization.dataset.configure[lang]}}</span>
            </router-link>
          </div>
          <div class="navbar-item" v-if="!loadingDatasets && $route.params.dataset">
            <a
              class="button is-link is-outlined"
              @click="downloadSample($route.params.dataset)"
            >
              <span class="icon"><i class="fa fa-download" aria-hidden="true"></i></span>
              <span>{{localization.dataset.export[lang]}}</span>
            </a>
          </div>
          <div class="navbar-item" v-if="$route.params.recipe">
            <template v-if="recipeStatus === 'up'">
              <button
                v-if="stoppingStatus"
                class="button is-outlined is-danger"
                disabled
              >
                <span class="icon">
                  <i class="fa fa-spin fa-spinner"></i>
                </span>
                <span>{{localization.recipe.stopping[lang]}} ...</span>
              </button>
              <button
                v-else
                @mouseover="recipeState = 'stop'"
                @mouseleave="recipeState = 'running'"
                class="button is-outlined"
                :class="[
                  {'is-danger': recipeState === 'stop'},
                  {'is-warning' : recipeState === 'running'}
                ]"
                @click="stopRecipe($route.params.recipe)"
                :disabled="disabled"
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
              </button>
            </template>
            <button
              v-else-if="recipeStatus"
              class="button is-success is-outlined"
              @click="runRecipe($route.params.recipe)"
              :disabled="disabled"
            >
              <span class="icon"><i class="fa fa-play" aria-hidden="true"></i></span>
              <span>{{localization.recipe.run[lang]}}</span>
            </button>
          </div>
          <div class="navbar-item breadcrumb">
            <ul>
              <li>
                <span class="icon has-text-info">
                  <i v-if="$route.params.project !== undefined"
                    class="fa fa-connectdevelop mID-clickable"
                    @click="displayGraph = true"
                  ></i>
                </span>
                <a class="mID-unclickable" style="padding-top:0px;padding-bottom:0px;">
                  <span>{{ $route.params.project }}</span>
                </a>
              </li>
            </ul>
            <a v-if="user !== null"
              class="button is-rounded"
              @click="logout">
              <span class="mID-margin-right-8"> {{user}} </span>
              <i class="fa fa-sign-out mID-clickable"></i>
            </a>
          </div>
        </div>
      </div>
    </div>

    <graph-view
      v-if="displayGraph"
      @close="displayGraph = false"
      :datasets="allDatasets"
      :recipes="allRecipes"
      :project="this.$route.params.project"
    ></graph-view>

    <login></login>
    <message></message>

    <new-object
      :display="newObject.display"
      :type="newObject.type"
      @close="newObject.display = false"
    ></new-object>

    <delete-object
      :display="deleteObject.display"
      :type="deleteObject.type"
      :name="deleteObject.name"
      @close="deleteObject.display = false"
    ></delete-object>

    <import-object
      :display="importObjectDisplay"
      @close="importObjectDisplay = false"
    ></import-object>
  </div>
</template>

<script>
import GraphView from '@/components/Graph.vue'
import Login from '@/components/Login.vue'
import Message from '@/components/Helpers/FloatingMessage.vue'
import NewObject from '@/components/Object/New.vue'
import DeleteObject from '@/components/Object/Delete.vue'
import ImportObject from '@/components/Object/Import.vue'

export default {
  components: {
    GraphView,
    Message,
    Login,
    NewObject,
    DeleteObject,
    ImportObject
  },
  data () {
    let maxHeightCalc = window.screen.availHeight - 200
    return {
      burger: false,
      langs: [],
      dropdownMaxHeight: {maxHeight: maxHeightCalc + 'px'},
      // connectors
      connectors: [],
      loadingConnectors: true,
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
      disabled: false,
      recipeState: 'running',
      stoppingStatus: false,
      interval: {},
      // graph
      displayGraph: false,
      user: null,
      logged: false,
      // object
      newObject: {
        display: false,
        type: null
      },
      deleteObject: {
        display: false,
        type: null,
        name: null
      },
      importObjectDisplay: false,
      // jobs
      runningJobs: {},
      doneJobs: {}
    }
  },
  mounted () {
    this.langs = this.localization.available

    this.changeLang(this.lang)

    window.bus.$on('changeUser', (user) => {
      this.user = user
      window.bus.$emit('reloadNav')
    })
    window.bus.$on('reloadNav', () => {
      this.getConnectors()
      this.getProjects()
      this.getDependencies(this.$route.params.project)

      if (this.$route.params.recipe !== undefined) {
        this.getStatus(this.$route.params.recipe)

        this.interval.status = setInterval(() => {
          this.getStatus(this.$route.params.recipe)
        }, 5000)
      }
    })
    window.bus.$on('deleteObject', (object) => {
      this.deleteObject = {display: true, type: object.type, name: object.name}
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
    orderedDatasets () {
      let ordered = {}
      Object.keys(this.datasets).sort().forEach(key => {
        ordered[key] = this.datasets[key]
      })
      return ordered
    },
    orderedRecipes () {
      let ordered = {}
      Object.keys(this.recipes).sort().forEach(key => {
        ordered[key] = this.recipes[key]
      })
      return ordered
    }
  },
  methods: {
    isEmpty (obj) {
      return obj ? (Object.keys(obj).length === 0) : true;
    },
    pickBy (obj, filter) {
      return Object.keys(obj)
        .filter((key) => filter(obj[key]))
        .reduce((newObj, key) => { newObj[key] = obj[key]; return newObj; }, {})
    },
    shutdown () {
      fetch(this.apiUrl + 'shutdown/', {method: 'PUT'})
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              window.bus.$emit('message', {'title': this.localization.global.shutdown[this.lang], type: 'is-warning', message: json.message})
            })
          }
        },
        error => {
          window.bus.$emit('message', {'title': this.localization.global.shutdown[this.lang], type: 'is-danger', message: error.body.message})
        })
    },
    logout () {
      fetch(this.apiUrl + 'logout/', {method: 'POST'})
        .then(() => {
          this.$router.push({name: 'login'})
        })
    },
    changeLang (newLang) {
      this.lang = newLang
      window.bus.$emit('langChange', this.lang)
    },
    getConnectors () {
      this.loadingConnectors = true
      fetch(this.apiUrl + 'connectors/')
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.connectors = Object.keys(json).sort()
              window.bus.$emit('reloadConnectors', this.connectors)
              setTimeout(() => { this.loadingConnectors = false }, 500)
            })
          }
        })
    },
    getProjects () {
      this.loadingProjects = true
      fetch(this.apiUrl + 'conf/')
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.projects = Object.keys(json.projects).sort()
              window.bus.$emit('reloadProjects', this.projects)
              setTimeout(() => { this.loadingProjects = false }, 500)
            })
          }
        })
    },
    getDependencies (project) {
      if (project !== undefined) {
        this.getDatasets(project)
        this.getRecipes(project)
      }
    },
    getDatasets (project) {
      fetch(this.apiUrl + 'datasets/')
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.allDatasets = json
              this.datasets = this.pickBy(json, (v) => v.project === project)
              window.bus.$emit('reloadDatasets', this.datasets)
              setTimeout(() => { this.loadingDatasets = false }, 500)
            })
          }
        })
    },
    getRecipes (project) {
      fetch(this.apiUrl + 'recipes/')
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.allRecipes = json
              this.recipes = this.pickBy(json, (v) => v.project === project)
              window.bus.$emit('reloadRecipes', this.recipes)
              setTimeout(() => { this.loadingRecipes = false }, 500)
            })
          }
        })
    },
    downloadSample (dataset) {
      fetch(this.apiUrl + 'datasets/' + dataset + '/?type=csv', {method: 'POST'})
        .then(response => {
          var element = document.createElement('a')
          element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(response.data))
          element.setAttribute('download', dataset + '.csv')
          element.style.display = 'none'
          element.click()
          document.body.appendChild(element)
        })
    },
    runRecipe (recipe) {
      this.disabled = true
      this.stoppingStatus = false
      fetch(this.apiUrl + 'recipes/' + recipe + '/run', {method: 'PUT'})
        .then(() => {
          setTimeout(() => { this.disabled = false }, 6 * 1000)
        })
    },
    stopRecipe (recipe) {
      this.disabled = true
      this.stoppingStatus = true

      fetch(this.apiUrl + 'recipes/' + recipe + '/stop', {method: 'PUT'})
        .then(() => {
          this.disabled = false
        })
    },
    getStatus (recipe) {
      if (recipe !== undefined) {
        fetch(this.apiUrl + 'recipes/' + recipe + '/status')
          .then(response => {
            const contentType = response.headers.get("content-type")
            if(contentType && contentType.indexOf("application/json") !== -1) {
              return response.json().then( (json) => {
                this.recipeStatus = json.status
                if (this.recipeStatus === 'down') {
                  this.stoppingStatus = false
                  window.bus.$emit('lastRecipeLogs')
                } else {
                  window.bus.$emit('runningRecipeLogs')
                }
              })
            }
          })
      }
    },
    getJobs () {
      fetch(this.apiUrl + 'jobs')
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.runningJobs = json.running
              this.doneJobs = json.done
              if (this.$route.name === 'jobs' || this.$route.name === 'job') {
                window.bus.$emit('updateJobs', {running: json.running, done: json.done})
              }
            })
          }
        })
    }
  }
}
</script>

<style scoped lang="scss">
a.logo {
  line-height: 0;
    }
</style>
