<template>
  <div class="modal is-active" style="pointer-events: none;">
    <div class="modal-card is-fullheight is-fullwidth">
      <div class="modal-card-content is-fullheight">
      </div>
      <footer class="modal-card-footer">
        <div class="columns">
          <div class="column is-8">
          </div>

          <div class="column is-4">
            <transition name="slide-fade" v-for="message in messages">
              <article class="message" :class="message.type"  v-if="message.display" >
                <div class="message-header">
                  <p>{{message.title}}</p>
                  <button class="delete" style="pointer-events: auto;" aria-label="delete" @click="message.display = false"></button>
                </div>
                <div class="message-body has-text-centered">
                  {{message.message}}
                </div>
              </article>
            </transition>
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
      mid: 1,
      messages: [],
      timeout: {
        'is-danger': 20000,
        'is-alert': 10000,
        'is-info': 3000,
        'is-success': 1000,
        'is-warning': 3000
      }
    }
  },
  computed: {
    lastMessage () {
      return this.$lodash(this.messages).map(m => { return m.title })[0]
    },
    display () {
      if (this.messages !== []) {
        return this.messages.some(m => { return m.display })
      } else {
        return false
      }
    }
  },
  methods: {
    queueMessage (m) {
      this.messages = this.messages.filter(message => { return message.display })
      m.display = true
      this.messages.push(m)
      setTimeout(() => {
        m.display = false
      }, this.timeout[m.type])
    }
  },
  created () {
    let m = {
      title: 'Welcome',
      type: 'is-info',
      message: 'Further messages will appear here'
    }

    window.bus.$on('message', (m) => {
      this.queueMessage(m)
    })
    window.bus.$emit('message', m)
  }
}
</script>

<style lang="scss" scoped>

.slide-fade-enter-active {
  transition: all .3s ease;
}
.slide-fade-leave-active {
  transition: all .5s cubic-bezier(1.0, 0.5, 0.8, 1.0);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(200px);
  opacity: 0;
}

</style>
