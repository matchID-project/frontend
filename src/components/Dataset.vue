<template>
  <div id="dataset" class="columns is-fullheight is-gapless">
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
        <div class="card-content is-paddingless" style="height: calc(100% - 48px)">
          <yaml-editor
            :codeData="code"
            :saveCode="saveCode"
            :showFullScreen="showFullScreen"
            @codeSaved-dataset="sendCodeSaving"
            @showedFullScreen="showFullScreen = false"
          ></yaml-editor>
        </div>
        <footer class="card-footer">
          <a
            @click="showFullScreen = true"
            class="card-footer-item"
          >
            <span class="icon">
              <i class="fa fa-expand" aria-hidden="true"></i>
            </span>
            {{ localization.editor.fullScreen[lang] }}
          </a>
          <a
            @click="showShortcuts = true"
            class="card-footer-item"
          >
            <span class="icon">
              <i class="fa fa-keyboard-o" aria-hidden="true"></i>
            </span>
            {{ localization.editor.shortcuts.title[lang] }}
          </a>
          <a
            @click="fireCodeSaving()"
            class="card-footer-item"
            v-shortkey="['ctrl', 's']"
            @shortkey="fireCodeSaving()"
          >
            <span class="icon">
              <i class="fa fa-save" aria-hidden="true"></i>
            </span>
             {{ localization.editor.save[lang] }}
             <span class="icon" v-if="loadingSave">
               <i class="fa fa-spinner fa-spin"></i>
             </span>
             <transition name="fade">
               <span class="icon" v-if="completedSave">
                 <i class="fa fa-check"></i>
               </span>
             </transition>
          </a>
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
            console.log('error')
          } else {
            this.loadingSave = false
            this.completedSave = true
            this.saveCode = false
            setTimeout(() => {
              this.completedSave = false
            }, 3000)
            this.getData(this.$route.params.dataset)
          }
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
