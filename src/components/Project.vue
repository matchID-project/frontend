<template>
  <div id="project">
    <div class="hero">
      <section class="hero is-info">
        <div class="hero-body">
          <div class="container">
            <h1 class="title">
              {{ $route.params.project }}
            </h1>
          </div>
        </div>
      </section>
    </div>
    <section class="section">
      <div class="container">
        <div class="columns is-9">
          <div class="column is-half">
            <section class="hero is-primary box">
              <div class="hero-body">
                <div class="container">
                  <h1 class="title">
                    Datasets
                  </h1>
                </div>
              </div>
            </section>

            <div class="box" v-if="!$lodash.isEmpty(datasets)">
              <div class="menu">
                <template
                  v-for="type in ['upload', 'elasticsearch']"
                >
                  <p class="menu-label">
                    {{ type }}
                  </p>
                  <ul class="menu-list">
                    <li
                      v-for="(dataset, key) in orderedDatasets"
                      :key="dataset.table"
                      v-if="dataset.connector == type"
                    >
                      <router-link
                        :to="{ name: 'dataset', params: { dataset: key}}"
                        class="is-uppercase"
                      >{{ key }}</router-link>
                      <ul>
                        <li v-for="(elem, key) in {connector: 'Type', table: 'Source'}" :key="elem.key">
                          <a class="mID-unclickable">{{ elem }} : <code>{{ dataset[key] }}</code></a>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </template>
              </div>
            </div>

            <div class="columns">
              <div class="column is-half">
                <a class="hero is-small is-light box" @click="newObject={display: true, type: 'dataset'}">
                  <div class="hero-body">
                    <div class="container">
                      <h5 class="title is-5">
                        <span class="icon mID-margin-right-8"><i class="fa fa-download" aria-hidden="true"></i></span>
                        <span>{{ localization.object.import.dataset[lang] }}</span>
                      </h5>
                    </div>
                  </div>
                </a>
              </div>
              <div class="column is-half">
                <a class="hero is-small is-light box" @click="newObject={display: true, type: 'dataset'}">
                  <div class="hero-body">
                    <div class="container">
                      <h5 class="title is-5">
                        <span class="icon mID-margin-right-8"><i class="fa fa-plus" aria-hidden="true"></i></span>
                        <span>{{ localization.object.new.dataset[lang] }}</span>
                      </h5>
                    </div>
                  </div>
                </a>
              </div>
            </div>
          </div>

          <div class="column is-half">
            <section class="hero is-primary box">
              <div class="hero-body">
                <div class="container">
                  <h1 class="title">
                    Recipes
                  </h1>
                </div>
              </div>
            </section>

            <div class="box" v-if="!$lodash.isEmpty(recipes)">
              <div class="menu">
                <ul class="menu-list">
                  <li
                    v-for="(recipe, key) in orderedRecipes"
                    :key="recipe.table"
                  >
                    <router-link
                      :to="{ name: 'recipe', params: { recipe: key}}"
                      class="is-uppercase"
                    >{{ key }}</router-link>
                    <ul>
                      <li v-for="(elem, key) in {input: 'Input', output: 'Source', source: 'Source'}" :key="elem.key">
                        <a class="mID-unclickable" v-show="recipe[key]">{{ elem }} : <code>{{ recipe[key] }}</code></a>
                      </li>
                    </ul>
                  </li>
                </ul>
              </div>
            </div>

            <div class="columns">
              <div class="column is-half">
                <a class="hero is-small is-light box" @click="newObject={display: true, type: 'recipe'}">
                  <div class="hero-body">
                    <div class="container">
                      <h5 class="title is-5">
                        <span class="icon mID-margin-right-8"><i class="fa fa-download" aria-hidden="true"></i></span>
                        <span>{{ localization.object.import.recipe[lang] }}</span>
                      </h5>
                    </div>
                  </div>
                </a>
              </div>
              <div class="column is-half">
                <a class="hero is-small is-light box" @click="newObject={display: true, type: 'recipe'}">
                  <div class="hero-body">
                    <div class="container">
                      <h5 class="title is-5">
                        <span class="icon mID-margin-right-8"><i class="fa fa-plus" aria-hidden="true"></i></span>
                        <span>{{ localization.object.new.recipe[lang] }}</span>
                      </h5>
                    </div>
                  </div>
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <new-object
      :display="newObject.display"
      :type="newObject.type"
      @close="newObject.display = false"
    ></new-object>
  </div>
</template>

<script>
import NewObject from './Object/New'

export default {
  components: {
    NewObject
  },
  data () {
    return {
      datasets: {},
      recipes: {},
      // new object
      newObject: {
        display: false,
        type: null
      }
    }
  },
  computed: {
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
  watch: {
    '$route.params.project' () {
      this.getDependencies(this.$route.params.project)
    }
  },
  created () {
    this.getDatasets(this.$route.params.project)

    this.getRecipes(this.$route.params.project)
  },
  methods: {
    getDependencies (project) {
      this.getDatasets(project)

      this.getRecipes(project)
    },
    getDatasets (project) {
      this.$http.get(this.apiUrl + 'datasets')
        .then(response => {
          this.datasets = this.$lodash.pickBy(response.body, (v) => v.project === project)
        })
    },
    getRecipes (project) {
      this.$http.get(this.apiUrl + 'recipes')
        .then(response => {
          this.recipes = this.$lodash.pickBy(response.body, (v) => v.project === project)
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
