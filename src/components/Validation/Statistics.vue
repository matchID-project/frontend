<template>
  <div class="modal is-active">
    <div class="modal-background" @click="$emit('close')"></div>
      <div class="modal-content">
        <div class="card">
          <div class="card-header">
            <div class="card-header-title">
              <span class="icon">
                <i class="fa fa-bar-chart-o" aria-hidden="true"></i>
              </span>
              {{ localization.validation.statistics[lang] }}
            </div>
            <div class="card-header-icon">
              <button class="delete" @click="$emit('close')"></button>
            </div>
          </div>
          <div class="card-content">
            <stats-chart
              :chartData="dataFormattedForChartJs(statisticsRendered)"
              :options="optionsForChartJs()"
            ></stats-chart>
          </div>
          <div class="card-footer has-text-centered">
            <div
              class="card-footer-item"
              v-for="(agg, id) in (scores.aggs !== undefined) ? Object.keys(scores.aggs) : []"
              :key=id
            >
              <div class="level-left">
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary">{{ agg }}</p>
                    <p class="subtitle has-text-primary">{{ statisticsRendered.aggs.total[agg] }}</p>
                  </div>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <span class="title">&nbsp;&nbsp;&nbsp;&nbsp;</span>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <p class="heading has-text-info" style="color:rgba(150,177,224,1)">{{ localization.validation.statistics.labels.threshold.true[lang] }}</p>
                  <p class="has-text-info" style="color:rgba(150,177,224,1)">{{ statisticsRendered.aggs.threshold.total[agg] }}</p>
                </div>
              </div>
            </div>
            <div class="card-footer-item">
              <div class="level-left">
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary">{{ localization.validation.statistics.labels.distinct[lang] }}</p>
                    <p class="subtitle has-text-primary">{{ statisticsRendered.distinct.total }}</p>
                  </div>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <span class="title">&nbsp;&nbsp;&nbsp;&nbsp;</span>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <p class="heading has-text-info" style="color:rgba(150,177,224,1)">{{ localization.validation.statistics.labels.threshold.true[lang] }}</p>
                  <p class="has-text-info" style="color:rgba(150,177,224,1)">{{ statisticsRendered.distinct.threshold }}</p>
                </div>
              </div>
            </div>
            <div class="card-footer-item">
              <div class="level-left">
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary">{{ localization.validation.statistics.labels.total[lang] }}</p>
                    <p class="subtitle has-text-primary">{{ statisticsRendered.total }}</p>
                  </div>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <span class="title">&nbsp;&nbsp;&nbsp;&nbsp;</span>
                </div>
              </div>
              <div class="level-item has-text-centered">
                <div>
                  <p class="heading has-text-info" style="color:rgba(150,177,224,1)">{{ localization.validation.statistics.labels.threshold.true[lang] }}</p>
                  <p class="has-text-info" style="color:rgba(150,177,224,1)"> {{ statisticsRendered.threshold.total.true }}</p>
                </div>
              </div>
            </div>
            <div class="card-footer-item" v-if="statisticsRendered.decision.total.done !== 0">
              <div class="level-left">
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary">{{ localization.validation.statistics.labels.done[lang] }}</p>
                    <p class="subtitle has-text-primary">{{ statisticsRendered.decision.total.done }}</p>
                  </div>
                </div>
                <div class="level-item has-text-centered ">
                  <div>
                    <p class="heading" style="color:rgba(150,177,224,1)"> {{ localization.validation.statistics.labels.decision.true[lang] }} </p>
                    <p class="" style="color:rgba(150,177,224,1)">{{ statisticsRendered.decision.total.true }}</p>
                  </div>
                </div>
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading" style="color:rgba(254,80,101,1)"> {{ localization.validation.statistics.labels.decision.false[lang] }} </p>
                    <p class="" style="color:rgba(254,80,101,1)">{{ statisticsRendered.decision.total.false }}</p>
                  </div>
                </div>
              </div>
            </div>
            <div class="card-footer-item" v-if="statisticsRendered.decision.total.done != 0">
              <div class="level-left">
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary">{{ localization.validation.statistics.labels.evaluation.f1[lang] }}</p>
                    <p class="subtitle has-text-primary">{{ statisticsRendered.evaluation.f1 }}</p>
                  </div>
                </div>
                <div class="level-item has-text-centered ">
                  <div>
                    <p class="heading has-text-primary"> {{ localization.validation.statistics.labels.evaluation.precision[lang] }} </p>
                    <p class="has-text-primary">{{ statisticsRendered.evaluation.precision }}</p>
                  </div>
                </div>
                <div class="level-item has-text-centered">
                  <div>
                    <p class="heading has-text-primary"> {{ localization.validation.statistics.labels.evaluation.recall[lang] }} </p>
                    <p class="has-text-primary">{{ statisticsRendered.evaluation.recall }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>
import statsChart from '@/components/Validation/charts.js'

export default {
  components: {
    statsChart
  },
  props: {
    dataResults: {
      required: true,
      type: Object
    },
    scores: {
      required: true,
      type: Object
    },
    validationIndecisionDisplay: {
      required: true,
      type: Boolean
    }
  },
  computed: {
    statisticsRendered () {
      let data = {}
      console.log(this.dataResults);
      let choice = ['decision', 'threshold', 'true', 'false']
      let pick = ['false', 'true']
      if (Object.keys(this.dataResults).length > 0) {
        data.total = this.dataResults.hits.total.value
        data.distinct = {
          total: this.dataResults.aggregations.range.distinct.value,
          threshold: data.distinct = this.dataResults.aggregations.threshold.distinct.value
        }
        data.intervals = []
        data.intervals_count = []
        data.done_count = []
        data.aggs = { threshold: { total: {} } }
        if (this.scores.aggs !== undefined) {
          Object.keys(this.scores.aggs).forEach(element => {
            data.aggs[element] = []
            data.aggs.threshold[element] = []
          })
        }

        for (let i = 0; i < choice.length; i++) {
          data[choice[i]] = {}
          for (let j = 0; j < pick.length; j++) {
            data[choice[i]][pick[j]] = []
          }
        }
        data.decision.total = {
          'done': 0,
          'true': 0,
          'false': 0
        }

        for (var interval = 0; interval <= this.scores.range[1]; interval = interval + this.scores.statisticsInterval) {
          let find = this.dataResults.aggregations.scores.buckets[this.dataResults.aggregations.scores.buckets.findIndex(x => x.key === interval)]
          data.intervals.push(interval)
          if (!find) {
            data.intervals_count.push(0)
            data.done_count.push(0)
            if (this.scores.aggs !== undefined) {
              Object.keys(this.scores.aggs).forEach(element => {
                data.aggs[element].push(0)
                data.aggs.threshold[element].push(0)
              })
            }
            for (let i = 0; i < choice.length; i++) {
              for (let j = 0; j < pick.length; j++) {
                data[choice[i]][pick[j]].push(0)
              }
            }
          } else {
            data.intervals_count.push(find.doc_count)
            data.done_count.push(!find.done ? 0 : find.done.doc_count)
            data.threshold.true.push((interval >= this.scores.preComputed.decision) ? find.doc_count : 0)
            data.threshold.false.push((interval >= this.scores.preComputed.decision) ? 0 : find.doc_count)
            if (this.scores.aggs !== undefined) {
              Object.keys(this.scores.aggs).forEach(element => {
                data.aggs[element].push(find[element].value)
                data.aggs.threshold[element].push((interval >= this.scores.preComputed.decision) ? find[element].value : 0)
              })
            }
            for (let j = 0; j < pick.length; j++) {
              let val = find['decision'].buckets[find['decision'].buckets.findIndex(x => (x.key === pick[j]) || (x.key_as_string === pick[j]))]
              data.decision[pick[j]].push(val === void 0 ? 0 : val.doc_count)
              data.true[pick[j]].push((interval >= this.scores.preComputed.decision) ? (val === void 0 ? 0 : val.doc_count) : 0)
              data.false[pick[j]].push((interval >= this.scores.preComputed.decision) ? 0 : (val === void 0 ? 0 : val.doc_count))
            }
            // global stats
            data.total = data.total ? data.total.toLocaleString() : 0
            data.threshold.total = {}
            data.threshold.total.true = data.threshold.true.reduce((a, b) => a + b, 0).toLocaleString()
            data.threshold.total.false = data.threshold.false.reduce((a, b) => a + b, 0).toLocaleString()
            data.decision.total = {}
            data.decision.total.done = data.done_count ? data.done_count.reduce((a, b) => a + b, 0).toLocaleString() : 0
            data.decision.total.true = data.done_count ? data.decision.true.reduce((a, b) => a + b, 0).toLocaleString() : 0
            data.decision.total.false = data.done_count ? data.decision.false.reduce((a, b) => a + b, 0).toLocaleString() : 0
            data.evaluation = { 'true': {}, 'false': {} }
            data.evaluation.true.true = data.done_count ? data.true.true.reduce((a, b) => a + b, 0) : 0
            data.evaluation.false.true = data.done_count ? data.false.true.reduce((a, b) => a + b, 0) : 0
            data.evaluation.true.false = data.done_count ? data.true.false.reduce((a, b) => a + b, 0) : 0
            data.evaluation.false.false = data.done_count ? data.false.false.reduce((a, b) => a + b, 0) : 0
            data.evaluation.recall = data.done_count ? +(100 * data.evaluation.true.true / (data.evaluation.true.true + data.evaluation.false.true)).toFixed(1).toLocaleString() : this.localization.validation.statistics.labels.evaluation.null
            data.evaluation.precision = data.done_count ? +(100 * data.evaluation.true.true / (data.evaluation.true.true + data.evaluation.true.false)).toFixed(1).toLocaleString() : this.localization.validation.statistics.labels.evaluation.null
            data.evaluation.f1 = data.done_count ? +(2 * data.evaluation.precision * data.evaluation.recall / (data.evaluation.recall + data.evaluation.precision)).toFixed(1).toLocaleString() : this.localization.validation.statistics.labels.evaluation.null
            if (this.scores.aggs !== undefined) {
              data.aggs.total = {}
              Object.keys(this.scores.aggs).forEach(element => {
                data.aggs.total[element] = data.aggs[element].reduce((a, b) => a + b, 0).toLocaleString()
                data.aggs.threshold.total[element] = data.aggs.threshold[element].reduce((a, b) => a + b, 0).toLocaleString()
              })
            }
          }
        }
      }
      return data
    }
  },
  methods: {
    dataFormattedForChartJs (statistics) {
      if (Object.keys(this.dataResults).length === 0) return {}

      let datasets = [
        {
          label: this.localization.validation.statistics.labels.total[this.lang],
          borderColor: 'rgba(192,192,192,1)',
          backgroundColor: 'rgba(192,192,192,0.5)',
          data: statistics.intervals_count,
          borderDash: [10, 5],
          fill: false,
          // xAxisID: 'x-total',
          yAxisID: 'y-total'
        },
        {
          type: 'line',
          label: this.localization.validation.statistics.labels.done[this.lang],
          borderColor: 'rgba(0,49,137,1)',
          backgroundColor: 'rgba(0,49,137,1)',
          data: statistics.done_count,
          stack: false,
          fill: false,
          yAxisID: 'y-done'
        },
        {
          type: 'line',
          label: this.localization.validation.statistics.labels.decision.true[this.lang],
          borderColor: 'rgba(150,177,224,1)',
          backgroundColor: 'rgba(150,177,224,1)',
          data: statistics.decision.true,
          fill: true,
          stack: 'decision',
          yAxisID: 'y-decision'
        },
        {
          type: 'line',
          label: this.localization.validation.statistics.labels.decision.false[this.lang],
          borderColor: 'rgba(254,80,101,1)',
          backgroundColor: 'rgba(254,80,101,1)',
          data: statistics.decision.false,
          fill: true,
          stack: 'decision',
          yAxisID: 'y-decision'
        }
      ]
      if (this.scores.aggs !== undefined) {
        Object.keys(this.scores.aggs).forEach(element => {
          datasets.push({
            label: element,
            data: statistics.aggs[element],
            fill: false,
            yAxisID: 'y-total'
          })
        })
      }

      return {
        labels: statistics.intervals,
        datasets: datasets
      }
    },
    optionsForChartJs () {
      return {
        responsive: true,
        maintainAspectRatio: false,
        hoverMode: 'index',
        stacked: false,
        scales: {
          yAxes: [
            {
              type: 'linear',
              display: true,
              position: 'right',
              id: 'y-total'
            },
            {
              type: 'linear',
              display: false,
              position: 'left',
              stacked: true,
              id: 'y-done',
              gridLines: {
                drawOnChartArea: false // only want the grid lines for one axis to show up
              }
            },
            {
              type: 'linear',
              display: true,
              position: 'left',
              id: 'y-decision',
              scaleOverride: true,
              stacked: true,
              gridLines: {
                drawOnChartArea: false // only want the grid lines for one axis to show up
              }
            }
          ]
        },
        annotation: {
          annotations: [
            {
              drawTime: 'afterDatasetsDraw',
              id: 'threshold',
              type: 'line',
              mode: 'vertical',
              value: Math.round(this.scores.preComputed.decision / this.scores.statisticsInterval) * this.scores.statisticsInterval,
              scaleID: 'x-axis-0',
              label: {
                content: this.localization.validation.statistics.labels.threshold[this.lang] + ': ' + this.scores.preComputed.decision,
                enabled: true
              }
            }
          ]
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.modal-content {
  width: 75%
}
</style>
