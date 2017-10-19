<template>
  <div id="recipe" class="columns is-fullheight is-gapless">
    <div class="column is-3 is-fullheight">
      <div class="level is-fullheight loading-border" v-if="loadingCode">
        <div class="level-item">
          <span class="icon has-text-black-bis is-medium">
            <i class="fa fa-spinner fa-2x fa-spin"></i>
          </span>
        </div>
      </div>

      <div class="card is-fullheight" v-else>
        <div class="card-content is-paddingless" style="height: calc(100% - 48px)">
          <yaml-editor
            :codeData="code"
            :saveCode="saveCode"
            :showFullScreen="showFullScreen"
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
               <span class="icon" v-if="failedSave">
                 <i class="fa fa-times"></i>
               </span>
             </transition>
          </a>
        </footer>
      </div>
    </div>

    <div class="column is-9 is-fullheight">
      <div class="level is-fullheight loading-border" v-if="loadingData">
        <div class="level-item">
          <span class="icon has-text-black-bis is-medium">
            <i class="fa fa-spinner fa-2x fa-spin"></i>
          </span>
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
      failedSave: false, // indicator of save failed
      showShortcuts: false,
      showFullScreen: false,
      // data
      loadingData: true, // indicator of loading data
      data: null
    }
  },
  watch: {
    '$route.params.recipe' () {
      this.initCode(this.$route.params.recipe)
    }
  },
  mounted () {
    this.initCode(this.$route.params.recipe)

    window.bus.$on('codeSaved', newCode => {
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
          } else {
            this.loadingSave = false
            this.completedSave = true
            this.saveCode = false
            setTimeout(() => {
              this.completedSave = false
            }, 3000)
            this.getData(this.$route.params.recipe)
          }
        })
    })

    window.bus.$on('showedFullScreen', () => { this.showFullScreen = false })
  },
  methods: {
    initCode (recipe) {
      this.loadingCode = true
      this.loadingData = true

      this.$http.get(this.apiUrl + 'recipes/' + recipe)
        .then(response => {
          this.source = response.body.source
          this.getRecipeYaml(this.source)
        })

      this.getData(this.$route.params.recipe)
    },
    getRecipeYaml (nameOfFile) {
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
    getData (recipe) {
      this.$http.put(this.apiUrl + 'recipes/' + recipe + '/test')
        .then(response => {
          this.data = response.body.data
          this.columns = Object.keys(this.data[0])
          setTimeout(() => {
            this.loadingData = false
          }, 1500)
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
