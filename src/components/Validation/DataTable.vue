<template>
    <div id="table-wrapper">
      <div class="is-fullwidth">

        <template v-if="loading">
          <div class="has-text-centered loading-spinner">
            <span class="icon has-text-black-bis is-large">
              <i class="fa fa-3x fa-spinner fa-pulse"></i>
            </span>
          </div>
        </template>

        <div v-show="!loading" class="stickTable">
          <table class='table is-narrow is-bordered'>
            <table-header
              ref="tableHeaderRef"
              :columns="columns"
              :scrollContainer="'#table-wrapper'"
              :actions="actions"
              :view="view"
            />

            <tbody
              :class="{'activeShortcuts' : shortcutsActivation}"
            >
              <tr
                v-for="(entry, index) in data"
                :key="index"
                :tr-line="'tr-' + index"
                :class="[
                  {'operation-fade' : entry.validation},
                  {'operation-success' : entry.validation === 'success'},
                  {'operation-fail' : entry.validation === 'fail'},
                  index === activeRow ? 'border-selected' : 'fade-unselected'
                ]"
              >
                <td class="has-text-centered" v-show="view.display">
                  <a class="button is-small is-outlined" @click="getElasticsearchResponse(entry)">
                    <span class="icon">
                      <i class="fa fa-eye"></i>
                    </span>
                  </a>
                </td>
                <td
                  v-for="column in columns"
                  :key="Array.isArray(column.field) ? column.field.join() : column.field"
                  v-show="column.display"
                  :class="column.appliedClass ? column.appliedClass.body : ''"
                >
                  <span v-if="column.type === 'score'">
                    <progress-bar
                      :size="'small'"
                      :value="formattedField(entry[column.field], column.callBack)"
                      :max="scores.range.max"
                      :show-label="true"
                      :colors="scores.colors"
                    ></progress-bar>
                  </span>
                  <span
                    v-else
                    v-html="formattedField(Array.isArray(column.field) ? column.field.map((i) => entry[i]) : entry[column.field] , column.callBack)"
                  ></span>
                </td>

                <td v-show="actions.display">
                  <div class="field has-text-centered" :class="{'is-grouped' : actions.action.indecision_display}">
                    <p class="has-text-centered mID-nowrap" :class="{'mID-margin-right-8' : actions.action.indecision_display}">
                      <label class="checkbox">
                        <Toggle
                          v-model="entry.validation_decision"
                          :value="entry.validation_decision"
                          :color="{checked: '#00d1b2', unchecked: '#ff3860'}"
                          :sync="true"
                          :labels="{checked: 'ok', unchecked: 'ko'}"
                          @change="updateData(entry, 'decision')"
                        />
                      </label>
                    </p>
                    <p class="has-text-centered mID-nowrap" v-show="actions.action.indecision_display">
                      <label class="checkbox">
                        <input
                          type="checkbox"
                          v-model="entry.validation_indecision"
                          :checked="entry.validation_indecision"
                          :sync="true"
                          @change="updateData(entry, 'indecision')"
                        />
                          <i class="fa fa-question" :class="entry.validation_indecision ? 'has-text-black' : 'has-text-grey-lighter'" aria-hidden="true"></i>
                      </label>
                    </p>
                  </div>
                </td>

                <td v-show="actions.display">
                  <div class="field has-text-centered">
                    <p class="has-text-centered mID-nowrap">
                      <label class="checkbox">
                        <toggle
                          v-model="entry.validation_done"
                          offLabel="O"
                          onLabel="✅"
                          @change="updateData(entry, 'done')"
                        />
                      </label>
                    </p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div id="modal-wrapper">
        <elasticsearch-response
          v-show="elasticsearchResponseShow"
          :data="elasticsearchResponseData"
          :view="view"
          @close="elasticsearchResponseShow = false"
        ></elasticsearch-response>
      </div>
    </div>
</template>

<script>

import ProgressBar from '@/components/Helpers/ProgressBar.vue'
import ScrollManager from '@/components/Helpers/FixedHeader/ScrollManager.js'
import TableHeader from '@/components/Helpers/FixedHeader/TableHeader.vue'
import ElasticsearchResponse from '@/components/Validation/ElasticsearchResponse.vue'

import formatCell from '@/components/../assets/js/formatCell.js'
import Toggle from '@vueform/toggle'

export default {
  components: {
    ProgressBar,
    TableHeader,
    ElasticsearchResponse,
    Toggle
  },
  props: {
    columns: {
      required: true,
      type: Array
    },
    scores: {
      required: true,
      type: Object
    },
    view: {
      required: true,
      type: Object
    },
    actions: {
      required: true,
      type: Object
    },
    elasticsearch: {
      required: true,
      type: Object
    },
    inputData: {
      required: true,
      type: Array
    },
    loading: {
      type: Boolean,
      default: false,
      required: true
    }
  },
  data () {
    return {
      // JSON RESPONSE VIEW
      elasticsearchResponseShow: false,
      elasticsearchResponseData: {},
      activeRow: 0,
      screenHeightMiddle: 0,
      shortcutsActivation: false,
      data: []
    }
  },
  mounted () {
    this.data = this.inputData;
    const scrollManagerCallbacks = {}
    Object.assign(scrollManagerCallbacks, {
      reachedStart: () => this.$refs.tableHeaderRef.release(),
      inside: () => this.$refs.tableHeaderRef.stick()
    })

    this.scrollManager = new ScrollManager(scrollManagerCallbacks)

    const scrollContainerEl = document.querySelector('#table-wrapper')
    scrollContainerEl.className += ' stickTable-container'

    this.scrollManager.init(scrollContainerEl)

    this.initShortcuts()
  },
  destroyed () {
    this.scrollManager.destroy()
  },
  watch: {
    loading (newValue) {
      if (newValue) {
        this.resetShortcutsMode()
      } else {
        this.$refs.tableHeaderRef.justify()
      }
    }
  },
  methods: {
    getElasticsearchResponse (entry) {
      this.elasticsearchResponseShow = true

      this.elasticsearchResponseData = entry
    },
    initShortcuts () {
      this.screenHeightMiddle = window.screen.availHeight / 3

      document.addEventListener('keydown', event => {
        if (event.ctrlKey && event.altKey) {
          this.shortcutsActivation = !this.shortcutsActivation
        }

        if (this.shortcutsActivation) {
          if (event.keyCode === 40) { // down arrow
            this.moveDown()
            this.elasticsearchResponseShow = false
          } else if (event.keyCode === 38) { // up arrow
            this.moveUp()
            this.elasticsearchResponseShow = false
          }

          if (this.actions.display) {
            if (event.keyCode === 32) { // spacebar
              this.data[this.activeRow].validation_done = true
              this.updateData(this.data[this.activeRow], 'done')
              this.moveDown()
              this.elasticsearchResponseShow = false
            }

            if (event.keyCode === 65) { // change decision
              this.data[this.activeRow].validation_decision = !this.data[this.activeRow].validation_decision
            }

            if (event.keyCode === 69 && this.actions.action.indecision_display) { // change indecision
              this.data[this.activeRow].validation_indecision = !this.data[this.activeRow].validation_indecision
            }

            if (event.keyCode === 73) { // reload with random data
              window.bus.$emit('reloadData')
              this.elasticsearchResponseShow = false
            }

            if (event.keyCode === 68) { // json view
              if (this.elasticsearchResponseShow) {
                this.elasticsearchResponseShow = false
              } else {
                this.getElasticsearchResponse(this.data[this.activeRow])
              }
            }
          }

          event.preventDefault()
        }
      }, false)
    },
    resetShortcutsMode () {
      this.shortcutsActivation = false
      this.activeRow = 0
    },
    moveDown () {
      this.activeRow < (this.elasticsearch.size - 1) ? this.activeRow += 1 : null
      let downOffsetTop = document.querySelector("[tr-line='tr-" + this.activeRow + "']").offsetTop
      document.getElementById('table-wrapper').scrollTop = (downOffsetTop - this.screenHeightMiddle)
    },
    moveUp () {
      this.activeRow > 0 ? this.activeRow -= 1 : null
      let upOffsetTop = document.querySelector("[tr-line='tr-" + this.activeRow + "']").offsetTop
      document.getElementById('table-wrapper').scrollTop = (upOffsetTop - this.screenHeightMiddle)
    },
    formattedField (value, callback) {
      if ((value instanceof Array && value.includes(undefined)) || typeof value === 'undefined') {
        if (formatCell['formatUndefined']) {
          return formatCell['formatUndefined']()
        } else {
          return '<strong>ERROR :</strong><br/>' + value
        }
      }

      if (callback) return formatCell[callback](value)

      return value
    },
    updateData (entry, type) {
      if (type === 'done') {
        if (entry.validation_done) {
          this.updateDone(entry, this.actions.action.indecision_display).then(() => {
            entry.validation = 'success'
          }, error => {
            console.log(error)
            entry.validation = 'fail'
            entry.validation_done = false
          })
        } else {
          this.updateCancel(entry).then(() => {
            entry.validation = 'success'
          }, error => {
            console.log(error)
            entry.validation = 'fail'
            entry.validation_done = true
          })
        }
      } else {
        this.updateDone(entry, this.actions.action.indecision_display).then(() => {
          entry.validation = 'success'
          entry.validation_done = true
        }, error => {
          console.log(error)
          entry.validation = 'fail'
          entry.validation_done = false
        })
      }

      setTimeout(() => {
        entry.validation = null
      }, 3000)
    },
    updateDone (entry, indecision) {
      let script =
        'ctx._source.validation_decision = ' + entry.validation_decision + ';' +
        'ctx._source.validation_done = ' + Date.now() + 'L;'

      if (indecision) {
        script += 'ctx._source.validation_indecision = ' + entry.validation_indecision + ';'
      }

      return this.updateDocument(entry['_id'], script)
    },
    updateCancel (entry) {
      let script = 'ctx._source.remove(\'validation_decision\'); ctx._source.remove(\'validation_indecision\'); ctx._source.remove(\'validation_done\');'

      return this.updateDocument(entry['_id'], script)
    },
    updateDocument (id, script) {
      console.log({
        index: this.elasticsearch.index,
        id: id,
        body: {
          'script': script
        }
      })
      return fetch(`${this.elasticsearch.connection.host}/${this.elasticsearch.index}/_update/${id}`,
      {
        method: 'POST',
        headers: { "Content-Type": "application/json"},
        body: JSON.stringify({ script: script})
      })
    }
  }
}
</script>

<style src="@vueform/toggle/themes/default.css"></style>
