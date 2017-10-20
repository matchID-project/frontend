<template>
  <div class="is-fullheight" id="LogsViewer">
    <div class="level is-fullheight loading-border" v-if="loading">
      <div class="level-item">
        <span class="icon">
          <i class="fa fa-spinner fa-spin"></i>
        </span>
        <span>Loading logs</span>
      </div>
    </div>
    <div class="box is-overflowed is-fullheight is-size-7" v-else>
      <div class="columns">
        <div class="column is-11">
          <div
            v-for="(line, index) in arrayContent"
            v-if="index + 1 !== arrayContent.length"
            :key="line.index"
            :class="{'has-text-danger is-size-6' : line.match('Ooops')}"
          >
            <span class="icon is-small" v-if="line.match('Ooops')"><i class="fa fa-warning" aria-hidden="true"></i></span>
            <span class="icon is-small" v-else><i class="fa fa-circle-o" aria-hidden="true"></i></span>
            <span>{{ line }}</span>
          </div>
        </div>
        <div
          class="column is-1"
          :class="warningIndicator ? 'has-background-red' : 'has-background-green'"
        >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    content: String,
    loading: Boolean
  },
  data () {
    return {
      warningIndicator: false
    }
  },
  computed: {
    arrayContent () {
      let arr = this.content.split('\n')
      this.warningIndicator = arr.some(v => { return v.match('Ooops') })
      return arr
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
