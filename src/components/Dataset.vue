<template>
  <div id="dataset" class="columns is-mobile is-fullheight is-gapless">
    <div class="column is-3 is-fullheight">
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
            <i @click="showShortcuts = true" class="card-header-icon fa fa-question" aria-hidden="true"></i>
            <p class="card-header-title is-centered">
              <i class="fa fa-table mID-margin-right-8" aria-hidden="true"/>
              {{this.$route.params.dataset}}</p>
            <i @click="showFullScreen = true" class="card-header-icon fa fa-expand" aria-hidden="true"></i>
          </div>
        </header>
        <div class="card-content is-paddingless" style="height: calc(100% - 72px)">
          <yaml-editor
            :codeData="code"
            :saveCode="saveCode"
            :showFullScreen="showFullScreen"
            @codeSaved-dataset="sendCodeSaving"
            @showedFullScreen="showFullScreen = false"
          ></yaml-editor>
        </div>
        <footer class="card-footer">
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
        </footer>
      </div>
    </div>

    <div class="column is-9 is-fullheight">
      <div class="level is-fullheight loading-border" v-if="loadingData">
        <div class="level-item">
          <span class="icon has-text-black-bis is-medium mID-margin-right-8">
            <i class="fa fa-spinner fa-2x fa-spin"></i>
          </span>
          <span class="is-size-5">Loading Data</span>
        </div>
      </div>

      <div class="card is-fullheight" v-else>
        <data-viewer
          v-if="!loadingData"
          :data="data"
          :columns="columns"
        ></data-viewer>
      </div>
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

export default {
  components: {
    YamlEditor,
    Shortcuts,
    DataViewer
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
      failedSave: false, // indicator of save error
      showShortcuts: false,
      showFullScreen: false,
      // data
      loadingData: true, // indicator of loading data
      data: null
    }
  },
  watch: {
    '$route.params.dataset' () {
      this.initCode(this.$route.params.dataset)
    }
  },
  mounted () {
    this.initCode(this.$route.params.dataset)
  },
  methods: {
    initCode (dataset) {
      this.loadingCode = true
      this.loadingData = true

      this.$http.get(this.apiUrl + 'datasets/' + dataset)
        .then(response => {
          this.source = response.body.source
          this.getDatasetYaml(this.source)
        })

      this.getData(this.$route.params.dataset)
    },
    getDatasetYaml (nameOfFile) {
      return this.$http.get(this.apiUrl + 'conf/' + this.$route.params.project + '/' + nameOfFile)
        .then(response => {
          this.code = response.body
          setTimeout(() => {
            this.loadingCode = false
          }, 800)
        })
    },
    fireCodeSaving () {
      this.loadingSave = true
      this.saveCode = true
    },
    getData (dataset) {
      this.$http.post(this.apiUrl + 'datasets/' + dataset + '/')
        .then(response => {
          this.data = response.body.data
          this.columns = Object.keys(this.data[0])
          setTimeout(() => {
            this.loadingData = false
          }, 1500)
        })
    },
    sendCodeSaving (newCode) {
      this.$http.post(this.apiUrl + 'conf/' + this.$route.params.project + '/' + this.source, {yaml: newCode})
        .then(response => {
          var msg = response.body[Object.keys(response.body)[0]].yaml_validator
          if (msg !== 'yaml is ok') {
            this.failedSave = true
            this.saveCode = false
            this.loadingSave = false
            setTimeout(() => {
              this.failedSave = false
            }, 3000)
          } else {
            this.loadingSave = false
            this.completedSave = true
            this.saveCode = false
            this.failedSave = false
            setTimeout(() => {
              this.completedSave = false
            }, 3000)
            this.getData(this.$route.params.dataset)
          }
        },
        () => {
          this.loadingSave = false
          this.completedSave = false
          this.saveCode = false
          this.failedSave = true
          setTimeout(() => {
            this.failedSave = false
          }, 3000)
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
