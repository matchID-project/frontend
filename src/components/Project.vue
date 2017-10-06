<template>
  <div>
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
    <div class="container">
      <div class="columns">
        <div class="column is-half">
          <h2 class="title is-2">Datasets</h2>
          <div class="menu">
            <template
              v-for="type in ['upload', 'elasticsearch']"
            >
              <p class="menu-label">
                {{ type }}
              </p>
              <ul class="menu-list">
                <li
                  v-for="(dataset, key) in datasets"
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

        <div class="column is-half">
          <h2 class="title is-2">Recipes</h2>
          <div class="menu">
            <ul class="menu-list">
              <li
                v-for="(recipe, key) in recipes"
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
      </div>
    </div>
  </div>
</template>

<script>
import _ from 'lodash'

export default {
  data () {
    return {
      datasets: {},
      recipes: {}
    }
  },
  created () {
    this.getDatasets(this.$route.params.project)

    this.getRecipes(this.$route.params.project)
  },
  methods: {
    getDatasets (project) {
      this.$http.get(this.apiUrl + '/datasets')
        .then(response => {
          this.datasets = _.pickBy(response.body, (v) => v.project === project)
        })
    },
    getRecipes (project) {
      this.$http.get(this.apiUrl + '/recipes')
        .then(response => {
          this.recipes = _.pickBy(response.body, (v) => v.project === project)
        })
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
