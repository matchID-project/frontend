<template>
  <div id="project">
    <div class="hero">
      <section class="hero is-info">
        <div class="hero-body">
          <div class="level">
            <div class="level-left">
              <h1 class="level-item title">
                {{ $route.params.project }}
              </h1>
            </div>
            <div class="level-right is-hidden-mobile">
              <h1 class="level-item title"
                  @click="deleteObject = { name: $route.params.project,
                                           type: 'project',
                                           display: true }">
                <i class="fa fa-trash"/>
              </h1>
            </div>
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
                <div
                  v-for="(type, id) in ['upload', 'elasticsearch']"
                  :key="id"
                >
                  <p class="menu-label">
                    {{ type }}
                  </p>
                  <ul class="menu-list">
                    <li
                      v-for="(dataset, key) in orderedDatasets.filter(d => d.connector === type)"
                      :key="dataset.table"
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
                </div>
              </div>
            </div>

            <div class="columns">
              <div class="column is-half">
                <a class="hero is-small is-light box" @click="importObjectDisplay = true">
                  <div class="hero-body">
                    <div class="container">
                      <h5 class="title is-5">
                        <span class="icon mID-margin-right-8"><i class="fa fa-cloud-upload" aria-hidden="true"></i></span>
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
              <div class="column is-12">
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

    <import-object
      :display="importObjectDisplay"
      @close="importObjectDisplay = false"
    ></import-object>

    <delete-object
      :display="deleteObject.display"
      :type="deleteObject.type"
      :name="deleteObject.name"
      @close="deleteObject.display = false"
    ></delete-object>

  </div>
</template>

<script>
import NewObject from './Object/New'
import ImportObject from './Object/Import'
import DeleteObject from './Object/Delete'

export default {
  components: {
    NewObject,
    ImportObject,
    DeleteObject
  },
  data () {
    return {
      datasets: {},
      recipes: {},
      // new object
      newObject: {
        display: false,
        type: null
      },
      deleteObject: {
        display: false,
        type: null,
        name: null
      },
      importObjectDisplay: false
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
  created () {
    window.bus.$on('reloadDatasets', (datasets) => {
      this.datasets = datasets
    })
    window.bus.$on('reloadRecipes', (recipes) => {
      this.recipes = recipes
    })
  }
}
</script>

<style lang="scss" scoped>
.hero.is-small > .hero-body{
  padding: 1rem 1.5rem;
}
</style>
