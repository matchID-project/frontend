<template>
  <div id="validationWrapper" v-if="connectionMade">

    <div id="controller" v-show="!error.display">
      <div class="box">
        <div class="columns">

          <div class="column" :class="actions.display && !!scores.column ? 'is-4' : !actions.display && !scores.column ? 'is-6' : 'is-4'">
            <div class="field has-addons">
              <p class="control">
                <span class="select">
                  <select v-model='selectedSearchField'>
                    <option :value="'random'">Random</option>
                    <option 
                      v-for="column in columns"
                      :key="column.Label"
                      :value="Array.isArray(column.field) ? column.field.join() : column.field"
                      v-show="column.searchable"
                    >
                      {{column.label}}
                    </option>
                  </select>
                </span>
              </p>
              <p class="control has-icons-left">
                <input
                  class="input"
                  type="text"
                  v-model.trim="searchString"
                  :disabled="selectedSearchField === 'random'"
                >
                <span class="icon is-left">
                  <i class="fa fa-search"></i>
                </span>
              </p>
              <p class="control">
                <a
                  class="button"
                  @click="refreshData"
                >
                  <i class="fa fa-refresh" aria-hidden="true"></i>
                </a>
              </p>
            </div>
          </div>

          <div class="column" :class="actions.display ? 'is-3' : 'is-4'" v-show="!!scores.column">
              <div class="columns is-gapless">
                <div class="column is-2">
                  <div class="field">
                    <input class="input has-text-centered" type="text" name="min" v-model.number.lazy="valuesRangeSlider[0]">
                  </div>
                </div>
                <div class="column is-8" id="sliderWrapper">
                  <range-slider
                    :range="scores.range"
                    :values="valuesRangeSlider"
                    :color="'has-background-turquoise'"
                    @updateRangeSlider="updateValuesRangeSlider"
                  ></range-slider>
                </div>
                <div class="column is-2">
                  <div class="field">
                    <input class="input has-text-centered" type="text" name="max" v-model.number.lazy="valuesRangeSlider[1]">
                  </div>
                </div>
              </div>
          </div>

          <div class="column" :class="actions.display && !!scores.column ? 'is-2' : !actions.display && !scores.column ? 'is-6' : 'is-4'">
            <div class="field">
              <form id="search">
                <p class="control has-icons-left is-expanded">
                  <input
                    class="input"
                    type="text"
                    :placeholder="localization.validation.filter[lang]"
                    name="query"
                    v-model="filterQuery"
                  >
                  <span class="icon is-left">
                    <i class="fa fa-filter"></i>
                  </span>
                </p>
              </form>
            </div>
          </div>

          <div class="column is-2" v-show="actions.display">
            <div class="field">
              <p class="control">
                <label class="checkbox mID-checkbox">
                  <input
                    type="checkbox"
                    class="mID-margin-right-8"
                    v-model="displayOnlyUndone"
                    @change="refreshData"
                  >
                  {{ localization.validation.displayUndoneOnly[lang] }}
                </label>
              </p>
            </div>
          </div>

          <div class="column is-1">
            <div class="field">
              <p class="control has-text-centered">
                <a class="button is-outlined mID-margin-right-8" @click="shortcutsShow = true">
                  <span class="icon">
                    <i class="fa fa-keyboard-o"></i>
                  </span>
                </a>

                <a class="button is-outlined"
                  :class="{'has-text-danger mID-unclickable' : error.display}"
                  v-show="actions.display"
                  @click="statisticsRender"
                  :disabled="error.display"
                >
                  <span class="icon">
                    <i class="fa fa-bar-chart-o"></i>
                  </span>
                </a>
              </p>
            </div>
          </div>

        </div>
      </div>
    </div>

    <template id="modal">
      <message
        v-show="error.display"
        :type="error.type"
      >
        <span slot="header">
          <b>{{ localization.validation.mistake[lang] }}</b>
        </span>
        <slot>
          {{error.message}}
        </slot>
      </message>

      <statistics
        v-show="actions.display && statisticsShow"
        @close="statisticsShow = false"
        :dataResults="statisticsResults"
        :scores="scores"
        :validationIndecisionDisplay="actions.action.indecision_display"
      ></statistics>

      <shortcuts
        v-show="shortcutsShow"
        :validationDisplay="actions.display"
        @close="shortcutsShow = false"
      ></shortcuts>
    </template>

    <data-table
      :inputData="filteredData"
      :columns="columns"
      :scores="scores"
      :view="view"
      :actions="actions"
      :elasticsearch="elasticsearch"
      :esClient="esClient"
      :loading="loading"
    ></data-table>

  </div>
</template>

<script>
import RangeSlider from '../Helpers/RangeSlider'
import Message from '../Helpers/Message'
import DataTable from './DataTable'
import elasticsearchLib from 'elasticsearch'
import Statistics from './Statistics'
import Shortcuts from './Shortcuts'

export default {
  components: {
    RangeSlider,
    DataTable,
    Message,
    Statistics,
    Shortcuts
  },
  data () {
    return {
      // CONF
      columns: null,
      scores: null,
      view: null,
      actions: null,
      elasticsearch: null,
      connectionMade: false,
      // OUTPUT PROPS DATA-TABLE + ALL PROPS INCOMING
      loading: false,
      dataTable: [],
      // OUTPUT PROPS RANGE-SLIDER
      valuesRangeSlider: [],
      // CONTROLLER
      searchString: '',
      filterQuery: '',
      selectedSearchField: 'random',
      displayOnlyUndone: false,
      // KEYBOARD
      shortcutsShow: false,
      // STATISTICS
      statisticsShow: false,
      statisticsResults: {},
      // ERRORS
      error: {
        display: false,
        message: '',
        type: ''
      },
      // ES CLIENT
      esClient: {}
    }
  },
  created () {
    this.$http.put(this.apiUrl + 'datasets/' + this.$route.params.dataset + '/validation')
      .then(response => {
        this.columns = response.body.props.columns
        this.scores = response.body.props.scores
        this.view = response.body.props.view
        this.actions = response.body.props.actions
        this.elasticsearch = response.body.props.elasticsearch

        this.connectionMade = true

        this.valuesRangeSlider = this.scores.range

        if (this.elasticsearch.connection.host.match(/^\//) || this.elasticsearch.connection.host === '') {
          this.elasticsearch.connection.host = window.location.host + this.elasticsearch.connection.host
        }
        this.esClient = new elasticsearchLib.Client(this.elasticsearch.connection)

        this.refreshData()
      })
  },
  mounted () {
    window.bus.$on('reloadData', () => {
      this.refreshData()
    })
  },
  computed: {
    filteredData () {
      let filterQuery = this.filterQuery && this.filterQuery.toLowerCase()
      let data = this.dataTable

      if (filterQuery) {
        data = data.filter(row => {
          return Object.keys(row).some(key => {
            return String(row[key]).toLowerCase().indexOf(filterQuery) > -1
          })
        })
      }

      if (this.valuesRangeSlider[0] !== 0 || this.valuesRangeSlider[1] !== 100) {
        data = data.filter(row => {
          return row.confiance >= this.valuesRangeSlider[0] && row.confiance <= this.valuesRangeSlider[1]
        })
      }

      return data
    }
  },
  methods: {
    refreshData () {
      this.dataTable = []
      this.valuesRangeSlider = this.scores.range
      this.filterQuery = ''
      this.getData()
    },
    getData () {
      this.loading = true
      return this.search(this.searchString, this.selectedSearchField).then(response => {
        response.hits.hits.forEach(element => {
          if (this.displayOnlyUndone || !element._source.validation_done) {
            if (this.actions.display) {
              if (this.scores.column) {
                element._source.validation_decision = (element._source.validation_decision === undefined) ? element._source[this.scores.column] > this.scores.preComputed.decision : element._source.validation_decision

                element._source.validation_done = (element._source.validation_done === undefined) ? false : element._source.validation_done

                if (this.actions.action.indecision_display) {
                  element._source.validation_indecision = (element._source.validation_indecision === undefined) ? Array.isArray(this.scores.preComputed.indecision) && element._source[this.scores.column] <= this.scores.preComputed.indecision[1] && element._source[this.scores.column] >= this.scores.preComputed.indecision[0] : element._source.validation_indecision
                }
              } else {
                element._source.validation_decision = !element._source.validation_decision ? false : element._source.validation_decision

                element._source.validation_done = !element._source.validation_done ? false : element._source.validation_done

                if (this.actions.action.indecision_display) {
                  element._source.validation_indecision = !element._source.validation_indecision ? false : element._source.validation_indecision
                }
              }

              element._source.validation = false
            }
            this.dataTable.push(Object.assign(element._source, {_id: element._id}))
          }
        })
        this.loading = false
      }, error => {
        this.manageError(error)
      })
    },
    search (query, fields) {
      if (fields.includes(',')) {
        return this.esClient.search({
          index: this.elasticsearch.index,
          size: this.elasticsearch.size,
          body: {
            query: {
              multi_match: {
                query: query,
                fields: fields.split(',')
              }
            }
          }
        })
      } else if (fields === 'random') {
        return this.esClient.search({
          index: this.elasticsearch.index,
          size: this.elasticsearch.size,
          body: {
            query: {
              function_score: {
                query: {
                  range: {
                    [this.scores.column]: {
                      'gte': this.valuesRangeSlider[0],
                      'lte': this.valuesRangeSlider[1]
                    }
                  }
                },
                functions: [
                  {
                    random_score: {}
                  }
                ]
              }
            }
          }
        })
      }

      return this.esClient.search({
        index: this.elasticsearch.index,
        size: this.elasticsearch.size,
        q: fields + ':' + query
      })
    },
    updateValuesRangeSlider (valueRange) {
      this.valuesRangeSlider = valueRange.map(v => {
        return Number.parseInt(v)
      })
    },
    statisticsRender () {
      this.statisticsShow = true

      this.getStatistics()
    },
    getStatistics () {
      this.getElasticsearchStatistics().then(response => {
        this.statisticsResults = Object.assign({}, this.statisticsResults, response)
      }, error => {
        this.manageError(error)
      })
    },
    getElasticsearchStatistics () {
      let aggs = {}
      if (this.scores.aggs !== undefined) {
        aggs = this.$lodash.clone(this.scores.aggs)
      }
      aggs.decision = {
        terms: {
          field: 'validation_decision'
        }
      }
      aggs.done = {
        filter: {
          exists: {
            field: 'validation_done'
          }
        }
      }

      return this.esClient.search({
        index: this.elasticsearch.index,
        size: 0,
        body: {
          aggs: {
            threshold: {
              filter: {
                range: {
                  [this.scores.column]: {
                    'gte': this.scores.preComputed.decision,
                    'lte': this.valuesRangeSlider[1]
                  }
                }
              },
              aggs: {
                distinct: {
                  cardinality: {
                    field: this.scores.id || 'matchid_id'
                  }
                }
              }
            },
            range: {
              filter: {
                range: {
                  [this.scores.column]: {
                    'gte': this.valuesRangeSlider[0],
                    'lte': this.valuesRangeSlider[1]
                  }
                }
              },
              aggs: {
                distinct: {
                  cardinality: {
                    field: this.scores.id || 'matchid_id'
                  }
                }
              }
            },
            scores: {
              histogram: {
                field: 'confiance',
                interval: this.scores.statisticsInterval
              },
              aggs: aggs
            }
          }
        }
      })
    },
    manageError (errorMessage) {
      this.error.display = true
      this.error.message = errorMessage
      this.error.type = 'danger'
    }
  }
}
</script>
