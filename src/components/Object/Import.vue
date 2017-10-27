<template>
  <div class="modal is-active">
    <div class="modal-background" @click="close()"></div>
      <div class="modal-content">
        <div class="card">
          <div class="card-header">
            <div class="card-header-title">
              <i class="fa fa-bars mID-margin-right-8" aria-hidden="true"></i> {{ localization.object[action+type][lang] }}
            </div>
            <div class="card-header-icon">
              <button class="delete" @click="close()"></button>
            </div>
          </div>

          <div class="card-content has-text-centered">
            <div v-show="action == 'new' || type == 'project'" class="level">
              <div class="level-item has-text centered">
                <form>
                  {{ localization.object['name'+type][lang] }} &nbsp;
                  <input name="objectName"
                    @keyup.enter="saveObject(name)"
                    v-model="name"
                    :placeholder="localization.object['name'+type][lang].replace(/[^a-z0-9]/gi, '_').toLowerCase()"
                  >
                </form>
              </div>
              <div class="level-item has-text centered">
                <button
                  class="button is-primary"
                  @click="saveObject(name)"
                >
                  {{ localization.object.save[lang] }}
                </button>
              </div>
            </div>
            <dropzone
              v-show="action == 'import'" id="myVueDropzone"
              :url="url"
              v-on:vdropzone-success="showSuccess"
              :dropzone-options="customOptionsObject"
              :max-file-size-in-m-b="1000"
            >
              <!-- Optional parameters if any! -->
            </dropzone>
            <message class="is-6"
                v-show="error.display"
                :type="error.type"
            >
                <span slot="header" >
                    <b v-if="error.type !== 'success' ">{{ localization.object.mistake[lang] }}</b>
                    <b v-else="error.type ">{{ localization.object.success[lang] }}</b>
                </span>
                <span slot="button">
                  <button class="delete"  @click="error.display = false"></button>
                </span>
                <slot class="is-small">
                  {{error.message}}
                </slot>
            </message>
          </div>
        </div>
      </div>
    <button class="modal-close is-large" @click="close()"></button>
  </div>
</template>

<script>
import Message from './Helpers/Message'
import Dropzone from 'vue2-dropzone'

export default {
  components: {
    Message,
    Dropzone
  },
  props: {
    type: String,
    action: String
  },
  data () {
    return {
      error: {
        display: false,
        type: 'success',
        message: ''
      },
      project: '',
      customOptionsObject: {
        language: this.localization.object.dropzoneDict[this.lang]
      },
      name: null
    }
  },
  computed: {
    url () {
      if (this.type === 'dataset') {
        return this.apiUrl + 'upload/'
      }
      return this.apiUrl + 'upload/'
    //   else if (this.type === 'recipe') {
    //     return this.apiUrl + 'conf/' + this.project + '/recipes/'
    //   } else if (this.type === 'project') {
    //     var name = this.name === null ? 'defaut_project' : this.name.replace(/[^a-z0-9]/gi, '_').toLowerCase()
    //     return this.apiUrl + 'conf/' + name + '/'
    //   }
    }
  },
  methods: {
    showSuccess (file) {
      if (this.type === 'dataset') {
        this.saveObject(file.upload.filename)
      }
    },
    close () {
      this.$emit('close')
      this.error = {
        display: false,
        type: 'success',
        message: ''
      }
      this.name = null
    },
    saveObject (name) {
      var table = name
      name = name.replace(/[^a-z0-9]/gi, '_').toLowerCase()
      var url
      var method
      var data
      var yaml
      console.log(this.project + '/' + name)
      if (this.type === 'project') {
        url = this.apiUrl + 'conf/' + name + '/'
        method = 'put'
      } else if (this.type === 'dataset') {
        url = this.apiUrl + 'conf/' + this.project + '/datasets/' + name + '.yml'
        method = 'post'
        yaml = `datasets:
  {name}:
    connector: upload
    table: {table}
    type: read_csv
    sep: "\\\\s+|,|;"
    encoding: "utf8"
`
        yaml = yaml.replace(/\{name\}/mg, name)
        yaml = yaml.replace(/\{table\}/mg, table)
        data = {
          yaml: yaml
        }
      } else if (this.type === 'recipe') {
        url = this.apiUrl + 'conf/' + this.project + '/recipes/' + name + '.yml'
        method = 'post'
        yaml = `recipes:
  {}:
    input: replace_input
    output: replace_output
    steps:
      - eval:
          - new_col: sha1(row)
`
        yaml = yaml.replace(/\{\}/mg, name)
        data = {
          yaml: yaml
        }
      }
      if (url !== undefined && method !== undefined) {
        this.$http[method](url, data)
          .then(
            response => {
              this.error = {
                display: 'true',
                type: 'success',
                message: response.body
              }
            },
            response => {
              this.error = {
                display: 'true',
                type: 'danger',
                message: response.body
              }
            }
        )
      }
    }
  },
  mounted () {
    window.bus.$on('projectChange', value => {
      this.project = value
    })
  }
}
</script>
