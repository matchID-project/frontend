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
                <i class="fa fa-connectdevelop mID-margin-right-8" aria-hidden="true"></i>
              </span>
              {{localization.navbar.projects[lang]}}
            </router-link>

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'project', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.newProject[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'project', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.importProject[lang] }}
              </a>

              <hr class="dropdown-divider">

              <router-link
                class="navbar-item"
                v-for="project in projects"
                :key="project.key"
                :class="{'is-active' : project === $route.params.project}"
                :to="{ name: 'project', params: { project: project}}"
              >
                <span class="icon has-text-info">
                  <i
                    class="fa mID-margin-right-8"
                    :class="{'fa-connectdevelop has-text-primary' : project === $route.params.project}"
                    @click="displayGraph = true"
                  ></i>
                </span>
                {{ project }}
              </router-link>
            </div>
          </div>

          <div v-if="$route.params.project" class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link">
              <span class="icon">
                <i class="fa fa-table mID-margin-right-8" aria-hidden="true"></i>
              </span>
              {{localization.navbar.datasets[lang]}}
            </a>

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'dataset', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.newDataset[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'dataset', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.importDataset[lang] }}
              </a>

              <hr class="dropdown-divider">

              <router-link
                class="navbar-item"
                v-for="(dataset, key) in datasets"
                :key="dataset.table"
                :class="{'is-active' : dataset === $route.params.dataset}"
                :to="{ name: 'dataset', params: { dataset: key}}"
              >
                <div class="level is-mobile">
                  <div class="level-left">
                    <div class="level-item">
                      <span class="icon">
                        <i
                          class="fa mID-margin-right-8"
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
                          class="fa mID-margin-right-8"
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
                <i class="fa fa-flask mID-margin-right-8" aria-hidden="true"></i>
              </span>
              {{localization.navbar.recipes[lang]}}
            </a>

            <div class="navbar-dropdown">
              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'recipe', action: 'new'}"
              >
                <span class="icon">
                  <i class ="fa fa-plus mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.newRecipe[lang] }}
              </a>

              <a
                class="navbar-item has-text-info"
                @click="newObject={show: true, type: 'recipe', action: 'import'}"
              >
                <span class="icon">
                  <i class ="fa fa-download mID-margin-right-8"></i>
                </span>
                {{ localization.dataprep.importRecipe[lang] }}
              </a>

              <hr class="dropdown-divider">

              <router-link
                class="navbar-item"
                v-for="(recipe, key) in recipes"
                :key="recipe.table"
                :class="{'is-active' : recipe === $route.params.recipe}"
                :to="{ name: 'recipe', params: { recipe: key}}"
              >
                {{ key }}
              </router-link>
            </div>
          </div>
        </div>

        <div class="navbar-end">
          <div class="navbar-item breadcrumb">
            <ul>
              <li><a class="mID-unclickable">{{ $route.params.project }}</a></li>
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
      projects: [],
      datasets: {},
      recipes: {},
      allDatasets: {},
      allRecipes: {},
      displayGraph: false
    }
  },
  mounted () {
    this.langs = this.localization.available

    this.changeLang(this.lang)

    this.getProjects()

    this.getDependencies(this.$route.params.project)
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
      this.$http.get(this.apiUrl + '/conf')
        .then(response => {
          this.projects = Object.keys(response.body.projects)
        })
    },
    getDependencies (project) {
      this.getDatasets(project)

      this.getRecipes(project)
    },
    getDatasets (project) {
      this.$http.get(this.apiUrl + '/datasets')
        .then(response => {
          this.allDatasets = response.body
          this.datasets = _.pickBy(response.body, (v) => v.project === project)
        })
    },
    getRecipes (project) {
      this.$http.get(this.apiUrl + '/recipes')
        .then(response => {
          this.allRecipes = response.body
          this.recipes = _.pickBy(response.body, (v) => v.project === project)
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
