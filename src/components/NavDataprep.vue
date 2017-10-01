<template>
  <div class="navbar-menu">

    <div class="navbar-start">
      <div class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link is-active">
          <span
            class="control"
             v-on:mouseover="loadProjectsList()"
          >
          <i class="fa fa-connectdevelop mID-margin-right-8" aria-hidden="true"></i>
          {{localization.navbar.projects[lang]}}
          </span>
        </a>
        <div class="navbar-dropdown">
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'project', action: 'new'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class ="fa fa-plus"></i> &nbsp; &nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item">
                  <span class="has-text-info">
                    {{ localization.dataprep.newProject[lang] }}
                  </span>
                </div>
              </div>
            </div>
          </a>
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'project', action: 'import'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class ="fa fa-upload"></i> &nbsp; &nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item">
                  <span class="has-text-info">
                    {{ localization.dataprep.importProject[lang] }}
                  </span>
                </div>
              </div>
            </div>
          </a>
          <a
            class="navbar-item"
            v-for="aProj in projects"
            :key="aProj.key"
            :class="{'is-active' : aProj === project}"
            @click="changeProj(aProj)"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa"></i> &nbsp; &nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item">
                  <span>
                    {{ aProj }}
                  </span>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
      <div v-show="project !== ''" class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link is-active">
          <span
            class="control"
             v-on:mouseover="loadObjectsList()"
          >
          <i class="fa fa-table mID-margin-right-8" aria-hidden="true"></i>

          {{localization.navbar.datasets[lang]}}
          </span>
        </a>
        <div class="navbar-dropdown">
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'dataset', action: 'new'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa fa-plus"></i>  &nbsp;&nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item has-text-info">
                 {{ localization.dataprep.newDataset[lang] }}
                </div>
              </div>
            </div>
          </a>
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'dataset', action: 'import'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa fa-upload"></i>  &nbsp;&nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item has-text-info">
                 {{ localization.dataprep.importDataset[lang] }}
                </div>
              </div>
            </div>
          </a>

          <a
            class="navbar-item"
            v-for="aDataset in datasets"
            :key="aDataset.key"
            :class="{'is-active': isActive(aDataset,'dataset') }"
            @click="changeObj(aDataset,'dataset')"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa" :class="[aDataset[Object.keys(aDataset)[0]].validation === true ? 'fa-check has-text-primary' : (isActive(aDataset,'dataset') ? 'fa-table has-text-primary' : '')]" @click="validateObj(aDataset)"></i>  &nbsp;&nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item">
                    {{ Object.keys(aDataset)[0] }}
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
      <div v-show="project !== ''" class="navbar-item has-dropdown is-hoverable">
        <a class="navbar-link is-active">
          <span
            class="control"
             v-on:mouseover="loadObjectsList()"            
          >
          <i class="fa fa-flask mID-margin-right-8" aria-hidden="true"></i>

           {{localization.navbar.recipes[lang]}} </span>
        </a>
        <div class="navbar-dropdown">
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'recipe', action: 'new'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa fa-plus"></i>  &nbsp;&nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item has-text-info">
                  {{ localization.dataprep.newRecipe[lang] }}
                </div>
              </div>
            </div>
          </a>
          <a
            class="navbar-item"
            @click="newObject={show: true, type: 'recipe', action: 'import'}"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i class="fa fa-upload"></i>  &nbsp;&nbsp;
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item has-text-info">
                  {{ localization.dataprep.importRecipe[lang] }}
                </div>
              </div>
            </div>
          </a>

          <a
            class="navbar-item"
            v-for="aRecipe in recipes"
            :key="aRecipe.key"
            :class="{'is-active': isActive(aRecipe,'recipe') }"
            @click="changeObj(aRecipe,'recipe')"
          >
            <div class="level is-mobile">
              <div class="level-left">
                <div class="level-item">
                  <span class="icon has-text-info">
                    <i
                      class="fa"
                      :class="'mID-margin-right-8 ' + [ (isRunning[Object.keys(aRecipe)[0]] === true ? 'fa-flask fa-spin has-text-danger' : ( isActive(aRecipe,'recipe') ? 'fa-flask has-text-primary' : ''))]"
                       @click="(isActive(aRecipe,'recipe') || isRunning[Object.keys(aRecipe)[0]] === true) ? runStopRecipe(aRecipe) : ''"
                    ></i> 
                  </span>
                </div>
              </div>
              <div class="level-right">
                <div class="level-item">
                    {{ Object.keys(aRecipe)[0] }}
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
    </div>

    <div class="navbar-end">
      <div class="navbar-item has-text-centered">
        <div class="hero has-text-right">
          <div class="level-item has-text-centered">
              <i v-show="project != ''" class="fa fa-connectdevelop" @click="graphShow = !graphShow"></i>&nbsp;&nbsp;            

            <div>
              <p class="title is-4">  {{project}} </p>
              <p></p>
              <p class="is-small"> {{Object.keys(object)[0]}} </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <new-object
      v-show="newObject.show"
      @close="newObject.show = false"
      :type="newObject.type"
      :action="newObject.action"
    ></new-object>

    <graph-view
      v-if="graphShow"
      @close="graphShow = false"
      :datasets="all_datasets"
      :recipes="all_recipes"
      :project="project"
    ></graph-view>   

  </div>
</template>

<script>
import NewObject from './NewObject'
import GraphView from './Graph'
import localization from '../assets/json/lang.json'
import apiConf from '../assets/json/backend.json'

let api = apiConf.api

export default {
  components: {
    NewObject,
    GraphView
  },
  data () {
    return {
      newObject: {
        show: false,
        type: 'project',
        action: 'new'
      },
      graphShow: false,
      localization: localization,
      langs: localization.available,
      lang: localization.default,
      validation: false,
      object: {},
      projects: [],
      project: '',
      all_datasets: {},
      all_recipes: {},
      isRunning: {},
      source: ''
    }
  },
  computed: {
    datasets () {
      var datasets = []
      for (var dataset in this.all_datasets) {
        if (this.all_datasets[dataset].project === this.project) {
          var obj = {}
          obj[dataset] = this.all_datasets[dataset]
          obj[dataset].type = 'dataset'
          datasets.push(obj)
        }
      }
      return datasets
    },
    recipes () {
      var recipes = []
      for (var recipe in this.all_recipes) {
        if (this.all_recipes[recipe].project === this.project) {
          var obj = {}
          obj[recipe] = this.all_recipes[recipe]
          obj[recipe].type = 'recipe'
          this.checkStatus(recipe)
          recipes.push(obj)
        }
      }
      return recipes
    }
  },
  methods: {
    changeProj (aProj) {
      this.project = aProj
      window.bus.$emit('projectChange', this.project)
      this.loadObjectsList()
    },
    changeObj (anObj, type) {
      console.log(anObj)
      var name = Object.keys(anObj)[0]
      anObj[name].type = type
      anObj[name].running = this.isRunning[name] && (type === 'recipe')
      if (this.object !== anObj) {
        this.validation = false
        window.bus.$emit('validationDisplay', false)
        this.object = anObj
        window.bus.$emit('objectChange', this.object)
      }
    },
    validateObj (anObj) {
      this.validation = true
      var w = window
      var name = Object.keys(anObj)[0]
      this.$http.put(api.url + '/datasets/' + name + '/validation')
        .then(response => {
          w.bus.$emit('validationConfig', response.body)
          w.bus.$emit('validationDisplay', true)
        })
    },
    loadProjectsList () {
      this.$http.get(api.url + '/conf/')
        .then(response => {
          this.projects = Object.keys(response.body.projects)
        },
        response => {
        })
    },
    loadObjectsList () {
      var vue = this
      this.$http.get(api.url + '/datasets/')
        .then(response => {
          vue.all_datasets = response.body
        },
        response => {
        })
      this.$http.get(api.url + '/recipes/')
        .then(response => {
          vue.all_recipes = response.body
        },
        response => {
        })
    },
    isActive (anObj, type) {
      return (Object.keys(this.object)[0] === Object.keys(anObj)[0]) &&
        (this.object[Object.keys(this.object)[0]].type === anObj[Object.keys(anObj)[0]].type)
    },
    checkStatus (name) {
      var vue = this
      this.$http.get(api.url + 'recipes/' + name + '/status')
        .then(response => {
          if (response.body.status === 'up') {
            vue.isRunning[name] = true
          } else {
            vue.isRunning[name] = false
          }
        })
    },
    runStopRecipe (aRecipe) {
      var vue = this
      var name = Object.keys(aRecipe)[0]

      if (vue.isRunning[name] === true) {
        this.$http.put(api.url + '/recipes/' + name + '/stop')
          .then(response => {
          })
      } else {
        this.$http.put(api.url + '/recipes/' + name + '/run')
          .then(response => {
          })
      }
      vue.isRunning[name] = !vue.isRunning[name]
    }
  },
  mounted () {
    let self = this

    this.loadProjectsList(this.project)

    window.bus.$on('langChange', function (value) {
      self.lang = value
    })

    window.bus.$on('projectChange', function (value) {
      self.project = value
      window.bus.$emit('objectChange', {})
    })

    window.bus.$on('objectChange', function (object) {
      self.object = object
    })
  }
}
</script>

<style scoped lang="less">
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
