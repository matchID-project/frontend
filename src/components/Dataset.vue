<template>
  <div id="dataset" class="columns is-mobile is-fullheight is-gapless">
    <div class="column" :class="[{'is-3' : showMode === 0},
                                 {'is-6' : showMode === 1}]">
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
              <i class="fa fa-table mID-margin-right-8" aria-hidden="true"/>
              {{this.$route.params.dataset}}
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
            @codeSaved-dataset="sendCodeSaving"
            @showedFullScreen="showMode = (showMode + 1) % 2"
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

    <div class="column is-fullheight" :class="[{'is-9' : showMode === 0},
                                               {'is-6' : showMode === 1}]">
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
import YamlEditor from '@/components/Editor/YamlEditor.vue'
import Shortcuts from '@/components/Editor/Shortcuts.vue'
import DataViewer from '@/components/DataViewer.vue'

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
      showMode: 0,
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

      fetch(this.apiUrl + 'datasets/' + dataset)
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.source = json.source
            })
          }
        })
      this.getDatasetYaml(this.$route.params.dataset)
      this.getData(this.$route.params.dataset)
    },
    getDatasetYaml (dataset) {
      return fetch(this.apiUrl + 'datasets/' + dataset + '/yaml')
        .then(response => {
          return response.text().then( (text) => {
            this.code = text
            setTimeout(() => {
              this.loadingCode = false
            }, 800)
          })
        },
        (err) => {
          this.loadingCode = false
          this.failedSave = true
          window.bus.$emit('message', {'title': 'error loading yaml of ' + dataset, type: 'is-danger', message: err.body})
        })
    },
    fireCodeSaving () {
      this.loadingSave = true
      this.saveCode = true
    },
    getData (dataset) {
      fetch(this.apiUrl + 'datasets/' + dataset + '/', { method: 'POST' })
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              this.data = json.data
              this.columns = Object.keys(this.data[0])
              setTimeout(() => {
                this.loadingData = false
              }, 1500)
            })
          }
        })
    },
    objectDelete () {
      window.bus.$emit('deleteObject', {'type': 'dataset', 'name': this.$route.params.dataset})
    },
    sendCodeSaving (newCode) {
      fetch(this.apiUrl + 'conf/' + this.$route.params.project + '/' + this.source,
        { method: 'POST', headers: { "Content-Type": "application/json"}, body: JSON.stringify({ yaml: newCode })})
        .then(response => {
          const contentType = response.headers.get("content-type")
          if(contentType && contentType.indexOf("application/json") !== -1) {
            return response.json().then( (json) => {
              const msg = json[Object.keys(json)[0]].yaml_validator
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
                window.bus.$emit('messagemessage', {'title': 'saving ok', type: 'is-success', message: this.source + ' was successfully saved'})
                setTimeout(() => {
                  this.completedSave = false
                }, 3000)
                this.getData(this.$route.params.dataset)
              }
            })
          }
        },
        (err) => {
          this.loadingSave = false
          this.completedSave = false
          this.saveCode = false
          this.failedSave = true
          window.bus.$emit('message', {'title': 'error saving ' + this.source, type: 'is-danger', message: err.body})
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
