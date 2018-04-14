<template>
  <div class="modal is-active" v-if="display">
    <div class="modal-card is-fullheight is-fullwidth">
      <div class="modal-card-content is-fullheight">
      </div>
      <footer class="modal-card-footer">
        <div class="columns">
          <div class="column is-8">
          </div>

          <div class="column is-4">
              <article v-for="message in messages" class="message" :class="message.type"  v-if="message.display"  >
                <div class="message-header">
                  <p>{{message.title}}</p>
                  <button class="delete" aria-label="delete" @click="message.display = false"></button>
                </div>
                <div class="message-body has-text-centered">
                  {{message.message}}
                </div>
              </article>
          </div>
        </div>
      </footer>
    </div>
  </div>
</template>

<script>

export default {
  name: 'message',
  data () {
    return {
      messages: [{
        display: true,
        title: 'Message test',
        type: 'is-info',
        message: 'Ceci est un message de test'
      }]
    }
  },
  computed: {
    display () {
      return false
    }
  },
  methods: {
  },
  created () {
    let timeout = {
      'is-danger': 20000,
      'is-alert': 10000,
      'is-info': 3000,
      'is-success': 1000
    }

    setTimeout(() => {
      this.display = false
    }, 3000)
    window.bus.$on('message', (m) => {
      this.messages.append(m)
      setTimeout(() => {
        this.display = false
      }, timeout[this.type])
    })
  }
}
</script>

<style lang="scss" scoped>
</style>
