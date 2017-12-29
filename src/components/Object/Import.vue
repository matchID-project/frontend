<template>
  <div class="modal" :class="{'is-active' : display}">
    <div class="modal-background" @click="$emit('close')"></div>
      <div class="modal-card" v-if="display">
        <header class="modal-card-head">
          <p class="modal-card-title">
            <span class="icon">
              <i class="fa fa-table mID-margin-right-8"></i>
            </span>
            <span>{{ localization.object.import.dataset[lang] }}</span>
            <span class="icon" v-show="loadingAction"><i class="fa fa-spinner fa-pulse" aria-hidden="true"></i></span>
            <span class="icon" v-show="actionFinished"><i class="fa fa-check" aria-hidden="true"></i></span>
          </p>
          <button class="delete" aria-label="close" @click="$emit('close')"></button>
        </header>
        <section class="modal-card-body">
          <dropzone
            :id="'myVueDropzone'"
            :url="apiUrl + 'upload/'"
            @vdropzone-success="createDatasetYaml"
            :max-file-size-in-m-b="5000"
            :max-number-of-files="1"
            :use-font-awesome="true"
          />
        </section>
      </div>
    <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>
import Dropzone from 'vue2-dropzone'

export default {
  components: {
    Dropzone
  },
  props: {
    display: Boolean
  },
  data () {
    return {
      loadingAction: false,
      actionFinished: false,
      datasetYaml: `datasets:
  {name}:
    connector: upload
    table: {table}
    type: csv
    sep: "\\\\s+|,|;"
    encoding: "utf8"`
    }
  },
  methods: {
    createDatasetYaml (file) {
      this.loadingAction = true
      let table = file.upload.filename
      let name = table.replace(/[^a-z0-9]/gi, '_').toLowerCase()
      let url
      let data

      url = this.apiUrl + 'conf/' + this.$route.params.project + '/datasets/' + name + '.yml'
      data = { yaml: this.datasetYaml.replace(/\{name\}/mg, name).replace(/\{table\}/mg, table) }

      this.$http.post(url, data)
        .then(response => {
          setTimeout(() => {
            this.loadingAction = false
            this.actionFinished = true
          }, 500)

          window.bus.$emit('reloadNav')

          setTimeout(() => {
            this.$emit('close')
            this.actionFinished = false

            return this.$router.push({ name: 'dataset', params: { project: this.$route.params.project, dataset: name } })
          }, 1000)
        })
    }
  }
}
</script>
