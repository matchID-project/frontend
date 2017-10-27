<template>
  <div class="modal" :class="{'is-active' : display}">
    <div class="modal-background" @click="$emit('close')"></div>
      <div class="modal-card" v-if="display">
        <header class="modal-card-head">
          <p class="modal-card-title">
            <span class="icon">
              <i
                class="fa mID-margin-right-8"
                :class="[
                  {'fa-connectdevelop' : type === 'project'},
                  {'fa-table' : type === 'dataset'},
                  {'fa-flask' : type === 'recipe'}
                ]"
              ></i>
            </span>
            <span>{{ localization.object.new[type][lang] }}</span>
          </p>
          <button class="delete" aria-label="close" @click="$emit('close')"></button>
        </header>
        <section class="modal-card-body">
          <div class="field">
            <label class="label">{{ localization.object.name[type][lang] }}</label>
          </div>
          <div class="field has-addons">
            <div class="control is-expanded">
              <input
                class="input"
                type="text"
                @keyup.enter="saveObject()"
                v-model="nameOfNewObject"
                :placeholder="localization.object.name[type][lang].replace(/[^a-z0-9]/gi, '_').toLowerCase()"
              >
            </div>
            <p class="control has-text-right">
              <a class="button is-primary" @click="saveObject()">
                <span class="icon" v-show="loadingAction"><i class="fa fa-spinner fa-pulse" aria-hidden="true"></i></span>
                <span class="icon" v-show="actionFinished"><i class="fa fa-check" aria-hidden="true"></i></span>
                <span>{{ localization.object.new.action[lang] }}</span>
              </a>
            </p>
          </div>
        </section>
      </div>
    <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>

export default {
  props: {
    display: Boolean,
    type: String
  },
  data () {
    return {
      nameOfNewObject: null,
      loadingAction: false,
      actionFinished: false,
      yaml: {
        dataset: `datasets:
  {name}:
    connector: upload
    table: {table}
    type: csv
    sep: "\\\\s+|,|;"
    encoding: "utf8"`,
        recipe: `recipes:
  {}:
    input: replace_input
    output: replace_output
    steps:
      - eval:
          - new_col: sha1(row)`
      }
    }
  },
  methods: {
    saveObject () {
      this.loadingAction = true
      let table = this.nameOfNewObject
      let name = table.replace(/[^a-z0-9]/gi, '_').toLowerCase()
      let url
      let method
      let data

      if (this.type === 'project') {
        url = this.apiUrl + 'conf/' + name + '/'
        method = 'put'
      } else {
        method = 'post'
        url = this.apiUrl + 'conf/' + this.$route.params.project + '/' + this.type + 's/' + name + '.yml'

        if (this.type === 'dataset') {
          data = { yaml: this.yaml.dataset.replace(/\{name\}/mg, name).replace(/\{table\}/mg, table) }
        } else if (this.type === 'recipe') {
          data = { yaml: this.yaml.recipe.replace(/\{\}/mg, name) }
        }
      }

      this.$http[method](url, data)
        .then(response => {
          setTimeout(() => {
            this.loadingAction = false
            this.actionFinished = true
          }, 500)

          window.bus.$emit('reloadNav')

          setTimeout(() => {
            this.$emit('close')
            this.actionFinished = false

            if (this.type === 'project') return this.$router.push({ name: 'project', params: { project: name } })
            if (this.type === 'recipe') return this.$router.push({ name: 'recipe', params: { project: this.$route.params.project, recipe: name } })
            if (this.type === 'dataset') return this.$router.push({ name: 'dataset', params: { project: this.$route.params.project, dataset: name } })
          }, 1000)
        })
    }
  }
}
</script>
