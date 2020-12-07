<template>
  <div id="recipe" class="columns is-fullheight is-gapless">
    <div class="column" :class="[{'is-3' : showMode === 0},
                                 {'is-8' : showMode === 1}]">
      <div class="level is-fullheight loading-border" v-if="loadingCode">
        <div class="level-item">
          <span class="icon has-text-black-bis is-medium mID-margin-right-8">
            <i class="fa fa-spinner fa-2x fa-spin"></i>
          </span>
          <span class="is-size-5">Loading Code</span>
        </div>
      </div>

      <div class="card is-fullheight" v-else>
        <header class="card-header">
          <div class="button is-primary is-fullwidth">
            <i v-if="showMode === 0" @click="showMode = 1" class="card-header-icon fa fa-plus" aria-hidden="true"></i>
            <i v-if="showMode === 1" @click="showMode = 0" class="card-header-icon fa fa-minus" aria-hidden="true"></i>
            <i v-if="showMode === 1" @click="showMode = 2" class="card-header-icon fa fa-expand" aria-hidden="true"></i>
            <p class="card-header-title is-centered">
              {{this.$route.params.recipe}}
            </p>
            <i @click="objectDelete()" class="card-header-icon fa fa-trash" aria-hidden="true"></i>
            <i @click="showShortcuts = true" class="card-header-icon fa fa-question" aria-hidden="true"></i>
          </div>
        </header>
        <div class="card-content is-paddingless" style="height: calc(100% - 72px)">
          <yaml-editor
            :codeData="code"
            :saveCode="saveCode"
            :showFullScreen="showMode === 2"
            @codeSaved-recipe="sendCodeSaving"
            @showedFullScreen="showMode = (showMode + 1) % 2"
          ></yaml-editor>
        </div>
        <div class="card-footer">
          <div  class="button is-fullwidth"
                :class="[{'is-info' : loadingSave === false},
                        {'is-success': completedSave === true},
                        {'is-danger': failedSave === true}
                        ]"
                @click="fireCodeSaving()"
                v-shortkey="['ctrl', 's']"
                @shortkey="fireCodeSaving()">
            <i class="card-footer-icon mID-margin-right-8"
              :class="[{'fa fa-times': (failedSave === true)},
                       {'fa fa-save': (loadingSave === false) && (completedSave === false) && (failedSave === false)},
                       {'fa fa-spinner fa-spin': loadingSave === true},
                       {'fa fa-check': (completedSave === true)}
                       ]"
              aria-hidden="true"></i>
             <p>{{ localization.editor.save[lang] }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="column is-fullheight" :class="[{'is-9' : showMode === 0},
                                               {'is-4' : showMode === 1}]">
      <div class="level is-fullheight loading-border" v-if="loadingData">
        <div class="level-item">
          <span class="icon has-text-black-bis is-medium mID-margin-right-8">
            <i class="fa fa-spinner fa-2x fa-spin"></i>
          </span>
          <span class="is-size-5">Loading Data</span>
        </div>
      </div>

      <template v-else>
        <div class="card" style="height: 75%">
          <data-viewer
            v-if="!loadingData"
            :data="data"
            :columns="columns"
          ></data-viewer>
        </div>
        <div class="card" style="height: 25%">
          <logs-viewer
            :loading="loadingLogs"
            :content="logs"
          ></logs-viewer>
        </div>
    </template>
    </div>

    <shortcuts
      v-show="showShortcuts"
      @close="showShortcuts = false"
    ></shortcuts>
  </div>
</template>

<script>
import YamlEditor from './Editor/YamlEditor'
import Shortcuts from './Editor/Shortcuts'
import DataViewer from './DataViewer'
import LogsViewer from './LogsViewer'

export default {
  components: {
    YamlEditor,
    Shortcuts,
    DataViewer,
    LogsViewer
  },
  data () {
    return {
      source: null,
      // editor
      code: null,
      loadingCode: true, // indicator of loading editor
      saveCode: false, // save code instruction
      loadingSave: false, // indicator of save running
      completedSave: false, // indicator of save completed
      failedSave: false, // indicator of save failed
      showShortcuts: false,
      showMode: 0,
      // data
      loadingData: true, // indicator of loading data
      data: null,
      // logs
      logs: '',
      loadingLogs: false
    }
  },
  watch: {
    '$route.params.recipe' () {
      this.initCode(this.$route.params.recipe)
    }
  },
  mounted () {
    this.initCode(this.$route.params.recipe)
  },
  methods: {
    initCode (recipe) {
      this.loadingCode = true
      this.loadingData = true

      this.$http.get(this.apiUrl + 'recipes/' + recipe)
        .then(response => { this.source = response.body.source })
      this.getRecipeYaml(this.$route.params.recipe)
      this.getData(this.$route.params.recipe)
    },
    getRecipeYaml (recipe) {
      return this.$http.get(this.apiUrl + 'recipes/' + recipe + '/yaml')
        .then(response => {
          this.code = response.body
          setTimeout(() => {
            this.loadingCode = false
          }, 800)
        },
        (err) => {
          this.loadingCode = false
          this.failedSave = true
          window.bus.$emit('message', {'title': 'error loading yaml of ' + recipe, type: 'is-danger', message: err.body})
        })
    },
    fireCodeSaving () {
      this.loadingSave = true
      this.saveCode = true
    },
    getData (recipe) {
      this.loadingLogs = true
      this.$http.put(this.apiUrl + 'recipes/' + recipe + '/test')
        .then(response => {
          this.data = response.body.data
          this.logs = response.body.log
          this.columns = Object.keys(this.data[0])
          this.loadingLogs = false
          setTimeout(() => {
            this.loadingData = false
          }, 1500)
        },
        (err) => {
          this.loadingLogs = false
          window.bus.$emit('message', {'title': 'error executing ' + recipe, type: 'is-danger', message: err.body})
        })
    },
    objectDelete () {
      window.bus.$emit('deleteObject', {'type': 'recipe', 'name': this.$route.params.recipe})
    },
    sendCodeSaving (newCode) {
      this.$http.post(this.apiUrl + 'conf/' + this.$route.params.project + '/' + this.source, {yaml: newCode})
        .then(response => {
          var msg = response.body[Object.keys(response.body)[0]].yaml_validator
          if (msg !== 'yaml is ok') {
            this.loadingSave = false
            this.saveCode = false
            this.failedSave = true
            setTimeout(() => {
              this.failedSave = false
            }, 3000)
            window.bus.$emit('message', {'title': 'warning loading ' + this.source, type: 'is-warning', message: msg})
          } else {
            this.loadingSave = false
            this.completedSave = true
            this.saveCode = false
            this.failedSave = false
            window.bus.$emit('message', {'title': 'saving ok', type: 'is-success', message: this.source + ' was successfully saved'})
            setTimeout(() => {
              this.completedSave = false
            }, 3000)
            this.getData(this.$route.params.recipe)
          }
        },
        (err) => {
          this.loadingSave = false
          this.completedSave = false
          this.saveCode = false
          this.failedSave = true
          setTimeout(() => {
            this.failedSave = false
          }, 3000)
          window.bus.$emit('message', {'title': 'error saving ' + this.source, type: 'is-danger', message: err.body})
        })
    }
  }
}
</script>

<style lang="scss" scoped>
.fade-leave-active {
  transition: opacity .5s
}
.fade-leave-to {
  opacity: 0
}
</style>
