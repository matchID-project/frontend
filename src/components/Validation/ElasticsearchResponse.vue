<template>
  <div class="modal is-active">
    <div class="modal-background" @click="$emit('close')"></div>
      <div class="modal-content">
        <div class="card">
          <div class="card-content">
            <vue-json-pretty :data="filteredData"/>
          </div>
        </div>
      </div>
    <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>
import VueJsonPretty from 'vue-json-pretty';
import 'vue-json-pretty/lib/styles.css';

export default {
  props: {
    data: {
      type: Object,
      required: true
    },
    view: {
      type: Object,
      required: true
    }
  },
  computed: {
    filteredData () {
      if (this.view.fields.names.length) {
        if (this.view.fields.operation === 'included') {
          Object.keys(this.data).map((v) => {
            !this.view.fields.names.includes(v) ? delete this.data[v] : null
          })
        } else if (this.view.fields.operation === 'excluded') {
          this.view.fields.names.forEach((v) => {
            delete this.data[v]
          })
        }
      }

      return this.data
    }
  }
}
</script>
