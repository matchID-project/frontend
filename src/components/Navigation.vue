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
          <div class="navbar-dropdown">
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
              :to="{ name: 'home'}"
              class="navbar-link"
            >
              <span class="icon">
                <i class="fa fa-connectdevelop" aria-hidden="true"></i>
              </span>
              {{localization.navbar.projects[lang]}}
            </router-link>

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Project', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.newProject[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Project', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download"></i>
                </span>
                {{ localization.object.importProject[lang] }}
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
                <i class="fa fa-table" aria-hidden="true"></i>
              </span>
              {{localization.navbar.datasets[lang]}}
            </a>

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Dataset', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.newDataset[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Dataset', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download"></i>
                </span>
                {{ localization.object.importDataset[lang] }}
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
                v-for="(dataset, key) in datasets"
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

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Recipe', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus"></i>
                </span>
                {{ localization.object.newRecipe[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'Recipe', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download"></i>
                </span>
                {{ localization.object.importRecipe[lang] }}
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
                v-for="(recipe, key) in recipes"
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
                <span>Stopping ...</span>
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
                <span v-if="recipeState === 'stop'">Stop</span>
                <span v-else-if="recipeState === 'running'">Running ...</span>
              </a>
            </template>
            <a
              v-else
              class="button is-success is-outlined"
              :disabled="!clickPossible"
              @click="runRecipe($route.params.recipe)"
            >
              <span class="icon"><i class="fa fa-play" aria-hidden="true"></i></span>
              <span>Run</span>
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
      :recipes="allRecipes"loadingRecipes
      :project="this.$route.params.project"
    ></graph-view>

  </div>
</template>

<script>
import _ from 'lodash'
import GraphView from './Graph'

export default {
  components: {
    GraphView
  },
  data () {
    return {
      langs: [],
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
      interval: null,
      // graph
      displayGraph: false
    }
  },
  mounted () {
    this.langs = this.localization.available

    this.changeLang(this.lang)

    this.getProjects()

    this.getDependencies(this.$route.params.project)

    if (this.$route.params.recipe) {
      this.getStatus(this.$route.params.recipe)

      this.interval = setInterval(() => {
        this.getStatus(this.$route.params.recipe)
      }, 3000)
    }
  },
  beforeDestroy () {
    clearInterval(this.interval)
  },
  watch: {
    '$route.params.project' () {
      this.getDependencies(this.$route.params.project)
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
          this.datasets = _.pickBy(response.body, (v) => v.project === project)
          setTimeout(() => { this.loadingDatasets = false }, 500)
        })
    },
    getRecipes (project) {
      this.$http.get(this.apiUrl + 'recipes')
        .then(response => {
          this.allRecipes = response.body
          this.recipes = _.pickBy(response.body, (v) => v.project === project)
          setTimeout(() => { this.loadingRecipes = false }, 500)
        })
    },
    runRecipe (recipe) {
      this.clickPossible = false
      this.stoppingStatus = false
      this.$http.put(this.apiUrl + 'recipes/' + recipe + '/run')
        .then(response => {
          setTimeout(() => { this.clickPossible = true }, 3 * 1000)
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
    }
  }
}
</script>

<style scoped lang="scss">
.nav {
  height: 2.75rem;
  > .container {
    min-height: 2.75rem;
  }
}
.nav-toggle {
  height: 2.75rem;
}
</style>
