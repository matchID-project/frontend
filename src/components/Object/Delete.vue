<template>
  <div class="modal" :class="{'is-active' : display}">
  <div class="modal-background" @click="$emit('close')"></div>
    <div class="modal is-active" v-if="display">
      <div class="columns is-fullwidth is-centered">
        <div class="column is-5">
          <div class="message is-danger is-fullwidth">
            <header class="message-header">
              <span class="icon">
                <i
                  class="fa mID-margin-right-8"
                  :class="[{'fa-exclamation-circle': (!loadingAction & !actionFinished) },
                           {'fa fa-spinner fa-pulse': loadingAction},
                           {'fa-check': actionFinished}]"
                ></i>
              </span>
              <span class="is-size-4">{{ localization.object.delete[type][lang] }} '{{name}}' ?</span>
              <button class="delete" aria-label="close" @click="$emit('close')"></button>
            </header>
            <section class="message-body has-text-centered">
              <span> {{ localization.object.delete.message[lang] }} </span>
              <p>&nbsp;</p>
              <button class="button is-danger" @click="deleteObject()">
                <span>{{ localization.object.delete.action[lang] }}</span>
              </button>
              <button class="button is-primary" @click="$emit('close')">
                <span>{{ localization.object.cancel.action[lang] }}</span>
              </button>
            </section>
          </div>
        </div>
      </div>
    </div>
  <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>

export default {
  props: {
    display: Boolean,
    type: String,
    name: String
  },
  data () {
    return {
      loadingAction: false,
      actionFinished: false
    }
  },
  methods: {
    deleteObject () {
      this.loadingAction = true
      let url = ''
      if (this.type === 'project') {
        url = this.apiUrl + 'conf/' + this.name + '/'
      } else if (this.type === 'recipe') {
        url = this.apiUrl + 'recipes/' + this.name + '/'
      } else if (this.type === 'dataset') {
        url = this.apiUrl + 'datasets/' + this.name + '/'
      }

      this.$http.delete(url)
        .then(response => {
          setTimeout(() => {
            this.loadingAction = false
            this.actionFinished = true
          }, 500)

          window.bus.$emit('reloadNav')

          setTimeout(() => {
            this.$emit('close')
            this.actionFinished = false

            if (this.type === 'project') return this.$router.push({ name: 'home', params: { project: name } })
          }, 1000)
        })
    }
  }
}
</script>
